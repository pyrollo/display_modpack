--[[
    font_api mod for Minetest - Library to add font display capability
    to display_api mod.
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

-- Fallback table
local fallbacks = dofile(font_api.path.."/fallbacks.lua")

-- Local functions
------------------

-- Returns number of UTF8 bytes of the first char of the string
local function get_char_bytes(str)
	local msb = str:byte(1)
	if msb ~= nil then
		if msb <  0x80 then return 1 end
		if msb >= 0xF0 then return 4 end
		if msb >= 0xE0 then	return 3 end
		if msb >= 0xC2 then	return 2 end
	end
end

-- Returns the unicode codepoint of the first char of the string
local function char_to_codepoint(str)
	local bytes = get_char_bytes(str)
	if bytes == 1 then
	    return str:byte(1)
	elseif bytes == 2 then
		return (str:byte(1) - 0xC2) * 0x40
			+ str:byte(2)
	elseif bytes == 3 then
		return (str:byte(1) - 0xE0) * 0x1000
			+ str:byte(2) % 0x40 * 0x40
			+ str:byte(3) % 0x40
	elseif bytes == 4 then -- Not tested
		return (str:byte(1) - 0xF0) * 0x40000
			+ str:byte(2) % 0x40 * 0x1000
			+ str:byte(3) % 0x40 * 0x40
			+ str:byte(4) % 0x40
	end
end

-- Split multiline text into array of lines, with <maxlines> maximum lines.
-- Can not use minetest string.split as it has bug if first line(s) empty
local function split_lines(text, maxlines)
	local lines = {}
	local pos = 1
	repeat
		local found = string.find(text, "\n", pos)
		found = found or #text + 1
		lines[#lines + 1] = string.sub(text, pos, found - 1)
		pos = found + 1
	until (maxlines and (#lines >= maxlines)) or (pos > (#text + 1))
	return lines
end

--------------------------------------------------------------------------------
--- Font class

local Font = {}
font_api.Font = Font

function Font:new(def)

	if type(def) ~= "table" then
		minetest.log("error",
			"[font_api] Font definition must be a table.")
		return nil
	end

	if def.height == nil or def.height <= 0 then
		minetest.log("error",
			"[font_api] Font definition must have a positive height.")
		return nil
	end

	if type(def.widths) ~= "table" then
		minetest.log("error",
			"[font_api] Font definition must have a widths array.")
		return nil
	end

	if def.widths[0] == nil then
		minetest.log("error",
			"[font_api] Font must have a char with codepoint 0 (=unknown char).")
		return nil
	end

	local font = table.copy(def)
	setmetatable(font, self)
	self.__index = self
	return font
end

--- Gets the next char of a text
-- @return Codepoint of first char,
-- @return Remaining string without this first char

function Font:get_next_char(text)
	local bytes = get_char_bytes(text)

	if bytes == nil then
		minetest.log("warning",
			"[font_api] Encountered a non UTF char, not displaying text.")
		return nil, ''
	end

	local codepoint = char_to_codepoint(text)

	-- Fallback mechanism
	if self.widths[codepoint] == nil then
		local char = text:sub(1, bytes)

		if fallbacks[char] then
			return self:get_next_char(fallbacks[char]..text:sub(bytes+1))
		else
			return 0, text:sub(bytes+1) -- Ultimate fallback
		end
	else
		return codepoint, text:sub(bytes+1)
	end
end

--- Returns the width of a given char
-- @param char : codepoint of the char
-- @return Char width

function Font:get_char_width(char)
	-- Replace chars with no texture by the NULL(0) char
	if self.widths[char] ~= nil then
		return self.widths[char]
	else
		return self.widths[0]
	end
end

--- Text height for multiline text including margins and line spacing
-- @param nb_of_lines : number of text lines (default 1)
-- @return Text height

function Font:get_height(nb_of_lines)
	if nb_of_lines == nil then nb_of_lines = 1 end

	if nb_of_lines > 0 then
		return
			(
				(self.height or 0) +
				(self.margintop or 0) +
				(self.marginbottom or 0)
			) * nb_of_lines +
			(self.linespacing or 0) * (nb_of_lines -1)
	else
		return nb_of_lines == 0 and 0 or nil
	end
end

--- Computes text width for a given text (ignores new lines)
-- @param line Line of text which the width will be computed.
-- @return Text width

function Font:get_width(line)
	local codepoint
	local width = 0
	line = line or ''

	while line ~= "" do
		codepoint, line = self:get_next_char(line)
		width = width + self:get_char_width(codepoint)
	end

	return width
end

--- Builds texture part for a text line
-- @param line Text line to be rendered
-- @param texturew Width of the texture (extra text is not rendered)
-- @param x Starting x position in texture
-- @param y Vertical position of the line in texture
-- @return Texture string

function Font:make_line_texture(line, texturew, x, y)
	local codepoint
	local texture = ""
	line = line or ''

	while line ~= '' do
		codepoint, line = self:get_next_char(line)

		-- Add image only if it is visible (at least partly)
		if x + self.widths[codepoint] >= 0 and x <= texturew then
			texture = texture..
				string.format(":%d,%d=font_%s_%04x.png",
				              x, y, self.name, codepoint)
		end
		x = x + self.widths[codepoint]
	end

	return texture
end

--- Builds texture for a multiline colored text
-- @param text Text to be rendered
-- @param texturew Width of the texture (extra text will be truncated)
-- @param textureh Height of the texture
-- @param maxlines Maximum number of lines
-- @param halign Horizontal text align ("left"/"center"/"right") (optional)
-- @param valign Vertical text align ("top"/"center"/"bottom") (optional)
-- @param color Color of the text (optional)
-- @return Texture string

function Font:make_text_texture(text, texturew, textureh, maxlines,
                                         halign, valign, color)
	local texture = ""
	local lines = {}
	local textheight = 0
	local y

	-- Split text into lines (limited to maxlines fist lines)
	for num, line in pairs(split_lines(text, maxlines)) do
		lines[num] = { text = line, width = self:get_width(line) }
	end

	textheight = self:get_height(#lines)

	if #lines then
		if valign == "top" then
			y = 0
		elseif valign == "bottom" then
			y = textureh - textheight
		else
			y = (textureh - textheight) / 2
		end
	end

	y = y + (self.margintop or 0)

	for _, line in pairs(lines) do
		if halign == "left" then
			texture = texture..
				self:make_line_texture(line.text, texturew,
				0, y)
		elseif halign == "right" then
			texture = texture..
				self:make_line_texture(line.text, texturew,
				texturew - line.width, y)
		else
			texture = texture..
				self:make_line_texture(line.text, texturew,
				(texturew - line.width) / 2, y)
		end

		y = y + self:get_height() + (self.linespacing or 0)
	end

	texture = string.format("[combine:%dx%d", texturew, textureh)..texture
	if color then texture = texture.."^[colorize:"..color end
	return texture
end
