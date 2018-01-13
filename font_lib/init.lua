--[[
    font_lib mod for Minetest - Library to add font display capability 
    to display_lib mod. 
    (c) Pierre-Yves Rollo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Global variables
-------------------

font_lib = {}
font_lib.name = minetest.get_current_modname()
font_lib.path = minetest.get_modpath(font_lib.name)
font_lib.registered_fonts = {}

-- Local variables
------------------

local default_font = false

-- Local functions
------------------

-- Split multiline text into array of lines, with <maxlines> maximum lines.

local function split_lines(text, maxlines)
	local splits = text:split("\n")
	if maxlines then
		local lines = {}
		for num = 1,maxlines do
			lines[num] = splits[num]
		end
		return lines
	else
		return splits
	end
end

-- Gets a default (settings or fist font)

local function get_default_font()
	-- First call
	if default_font == false then
		default_font = nil

		-- First, try with settings
		local settings_font = minetest.settings:get("default_font")

		if settings_font ~= nil and settings_font ~= "" then
			default_font = font_lib.registered_fonts[settings_font]

			if default_font == nil then
				minetest.log("warning", "Default font in settings (\""..
				             settings_font.."\") is not registered.")
			end
		end

		-- If failed, choose first font
		if default_font == nil then
			for _, font in pairs(font_lib.registered_fonts) do
				default_font = font
				break
			end
		end

		-- Error, no font registered
		if default_font == nil then
			minetest.log("error",
			             "No font registred, unable to choose a default font.")
		end
	end

	return default_font
end

-- Returns font properties to be used according to font_name

local function get_font(font_name)
	local font = font_lib.registered_fonts[font_name]

	if font == nil then
		local message

		if font_name == nil then
			message = "No font given"
		else
			message = "Font \""..font_name.."\" unregistered"
		end

		font = get_default_font()

		if font ~= nil then
			minetest.log("info", message..", using font \""..font.name.."\".")
		end
	end

	return font
end

-- Returns next char, managing ascii and unicode plane 0 (0000-FFFF).

local function get_next_char(text, pos)

	local msb = text:byte(pos)
	-- 1 byte char, ascii equivalent codepoints
	if msb < 0x80 then
	    return msb, pos + 1
    end

	-- 4 bytes char not managed (Only 16 bits codepoints are managed)
	if msb >= 0xF0 then
		return 0, pos + 4
	end

	-- 3 bytes char
	if msb >= 0xE0 then
		return (msb - 0xE0) * 0x1000
		       + text:byte(pos + 1) % 0x40 * 0x40
		       + text:byte(pos + 2) % 0x40,
		       pos + 3
	end

	-- 2 bytes char (little endian)
	if msb >= 0xC2 then
		return (msb - 0xC2) * 0x40 + text:byte(pos + 1),
		       pos + 2
	end

    -- Not an UTF char
	return 0, pos + 1
end

-- API functions
----------------

-- Computes text size for a given font and text (ignores new lines)
-- @param font_name Font to be used
-- @param text Text to be rendered
-- @return Rendered text (width, height)

function font_lib.get_text_size(font_name, text)
	local char
	local width = 0
    local pos = 1
	local font = get_font(font_name)

	if font == nil then
		return 0, 0
	else
		while pos <= #text do
			char, pos = get_next_char(text, pos)
			-- Replace chars with no texture by the NULL(0) char
			if font.widths[char] ~= nil then
				width = width + font.widths[char]
			else
				width = width + font.widths[0]
			end
		end
	end

	return width, font.height
end

--- Builds texture part for a text line
-- @param font_name Font to be used
-- @param text Text to be rendered
-- @param width Width of the texture (extra text is not rendered)
-- @param x Starting x position in texture
-- @param y Vertical position of the line in texture
-- @return Texture string

function font_lib.make_line_texture(font_name, text, width, x, y)
	local texture = ""
	local char
	local pos = 1
	local font = get_font(font_name)

	if font ~= nil then
		while pos <= #text do
			char, pos = get_next_char(text, pos)

			-- Replace chars with no texture by the NULL(0) char
			if font.widths[char] == nil then
                print(string.format("["..font_lib.name
                                    .."] Missing char %d (%04x)",char,char))
                char = 0
			end

			-- Add image only if it is visible (at least partly)
			if x + font.widths[char] >= 0 and x <= width then
				texture = texture..
					string.format(":%d,%d=font_%s_%04x.png",
					              x, y, font.name, char)
			end
			x = x + font.widths[char]
		end
	end

	return texture
end

--- Builds texture for a multiline colored text
-- @param font_name Font to be used
-- @param text Text to be rendered
-- @param texturew Width of the texture (extra text will be truncated)
-- @param textureh Height of the texture
-- @param maxlines Maximum number of lines
-- @param halign Horizontal text align ("left"/"center"/"right") (optional)
-- @param valign Vertical text align ("top"/"center"/"bottom") (optional)
-- @param color Color of the text (optional)
-- @return Texture string

function font_lib.make_multiline_texture(font_name, text, width, height, 
                                         maxlines, halign, valign, color)
	local texture = ""
	local lines = {}
    local textheight = 0
	local y, w, h

    for num, line in pairs(split_lines(text, maxlines)) do
        w, h = font_lib.get_text_size(font_name, line)
        lines[num] = { text = line, width = w, height = h, }
        textheight = textheight + h
    end

    if #lines then
        if valign == "top" then
            y = 0
        elseif valign == "bottom" then
            y = height - textheight
        else
            y = (height - textheight) / 2
        end
    end

	for _, line in pairs(lines) do
		if halign == "left" then
			texture = texture..
				font_lib.make_line_texture(font_name, line.text, width,
				0, y)
		elseif halign == "right" then
			texture = texture..
				font_lib.make_line_texture(font_name, line.text, width,
				width - line.width, y)
		else
			texture = texture..
				font_lib.make_line_texture(font_name, line.text, width,
				(width - line.width) / 2, y)
		end
		y = y + line.height
	end

	texture = string.format("[combine:%dx%d", width, height)..texture
	if color then texture = texture.."^[colorize:"..color end
	return texture
end

--- Register a new font
-- Textures corresponding to the font should be named after following patern :
-- font_<name>_<code>.png
-- <name> : name of the font
-- <code> : 4 digit hexadecimal unicode of the char
-- @param font_name Name of the font to register
-- If registering different sizes of the same font, add size in the font name
-- (e.g. times_10, times_12...).
-- @param height Font height in pixels
-- @param widths Array of character widths in pixels, indexed by UTF codepoints

function font_lib.register_font(font_name, height, widths)

	if font_lib.registered_fonts[font_name] ~= nil then
		minetest.log("error", "Font \""..font_name.."\" already registered.")
		return
	end

	if height == nil or height <= 0 then
		minetest.log("error", "Font \""..font_name..
		             "\" must have a positive height.")
		return
	end

	if type(widths) ~= "table" then
		minetest.log("error", "Font \""..font_name..
		             "\" must have a widths array.")
		return
	end

	if widths[0] == nil then
		minetest.log("error", "Font \""..font_name..
		             "\" must have a char with codepoint 0 (=unknown char).")
		return
	end

	font_lib.registered_fonts[font_name] =
		{ name = font_name, height = height, widths = widths }

	-- Force to choose again default font
	-- (allows use of fonts registered after start)
	default_font = false
end

--- Standard on_display_update entity callback.
-- Node should have a corresponding display_entity with size, resolution and 
-- maxlines fields and optionally halign, valign and color fields
-- @param pos Node position
-- @param objref Object reference of entity

function font_lib.on_display_update(pos, objref)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("display_text")
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	local entity = objref:get_luaentity()

	if entity and ndef.display_entities[entity.name] then
		local def = ndef.display_entities[entity.name]
		local font = get_font(def.font_name)

		objref:set_properties({ 
			textures={font_lib.make_multiline_texture(
				def.font_name, text,
				def.size.x * def.resolution.x * font.height,
				def.size.y * def.resolution.y * font.height,
				def.maxlines, def.halign, def.valign, def.color)},
			visual_size = def.size
		})
	end
end

