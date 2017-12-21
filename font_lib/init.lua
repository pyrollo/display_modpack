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

font_lib = {}
font_lib.path = minetest.get_modpath("font_lib")
font_lib.registered_fonts = {}

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

-- Returns next char, managing ascii and unicode plane 0 (0000-FFFF).

local function get_next_char(text, pos)
	pos = pos + 1
	local char = text:sub(pos, pos):byte()

	-- 1 byte char
	if char < 0x80 then
	    return char, pos
    end

	-- 4 bytes char not managed
	if char >= 0xF0 then
		pos = pos + 3
		return 0, pos
	end
		
	-- 3 bytes char not managed
	if char >= 0xE0 then
		pos = pos + 2
		return 0, pos
	end
		
	-- 2 bytes char (little endian)
	if char >= 0xC2 then
		pos = pos + 1
		return (char - 0xC2) * 0x40 + text:sub(pos, pos):byte(), pos
	end

    -- Not an UTF char
	return 0, pos

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

		if font_lib.fallback_font == nil then
			minetest.log("error", message.." and no other font registered.")
		else
			minetest.log("info", message..", using font \""..font_lib.fallback_font.."\".")
			font = font_lib.registered_fonts[font_lib.fallback_font]
		end
	end

	return font
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
    local pos = 0
	local font = get_font(font_name)

	if font == nil then
		return 0, 0
	else
		while pos < #text do
			char, pos = get_next_char(text, pos)
			-- Ignore chars with no texture
			if font.widths[char] ~= nil then
				width = width + font.widths[char]
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

--> ADD ALIGN
function font_lib.make_line_texture(font_name, text, width, x, y)
	local texture = ""
	local char
	local pos = 0
	local font = get_font(font_name)

	if font ~= nil then
		while pos < #text do
			char, pos = get_next_char(text, pos)
	
			-- Ignore chars with no texture
			if font.widths[char] ~= nil then
				-- Add image only if it is visible (at least partly)
				if x + font.widths[char] >= 0 and x <= width then
					texture = texture..
						string.format(":%d,%d=font_%s_%04x.png", 
						              x, y, font.name, char)
				end
				x = x + font.widths[char]
            else
                print(string.format("Missing char %d (%04x)",char,char))
			end
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
-- @param valign Vertical text align ("top" or "center")
-- @param color Color of the text
-- @return Texture string

function font_lib.make_multiline_texture(font_name, text, width, height, 
                                         maxlines, valign, color)
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
		texture = texture..
			font_lib.make_line_texture(font_name, line.text, width,
			(width - line.width) / 2, y)
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
-- If registering different sizes, add size in the font name (e.g. times_10, times_12...)
-- @param height Font height in pixels
-- @param widths Array of character widths in pixel, indexed by unicode number.

function font_lib.register_font(font_name, height, widths)
	if font_lib.registered_fonts[font_name] ~= nil then
		minetest.log("error", "Font \""..font_name.."\" already registered.")
		return
	end
	
	font_lib.registered_fonts[font_name] = 
		{ name = font_name, height = height, widths = widths }
	
	-- If no fallback font, set it (so, first font registered will be the default fallback font)
	if font_lib.fallback_font == nil then
		font_lib.fallback_font = font_name
	end	
end

--- Define the fallback font
-- This font will be used instead of given font if not registered.
-- @param font_name Name of the font to be used as fallback font (has to be registered).

function font_lib.set_fallback_font(font_name)
	if font_lib.registered_fonts[font_name] == nil then
		minetest.log("error", "Fallback font \""..font_name.."\" not registered.")
	else
		font_lib.fallback_font = font_name
	end
end

--- Standard on_display_update entity callback.
-- Node should have a corresponding display_entity with size, resolution and maxlines fields and 
-- optionally valign and color fields
-- @param pos Node position
-- @param objref Object reference of entity

function font_lib.on_display_update(pos, objref)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("display_text")
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	local entity = objref:get_luaentity()

	if entity and ndef.display_entities[entity.name] then
		local def = ndef.display_entities[entity.name]

		objref:set_properties({ 
			textures={font_lib.make_multiline_texture(
				def.font_name, text, def.size.x*def.resolution.x, def.size.y*def.resolution.y, 
				def.maxlines, def.valign, def.color)}, 
			visual_size = def.size
		})
	end
end

dofile(font_lib.path.."/font_default.lua")

