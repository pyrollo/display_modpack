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


--[[
	Margins, spacings, can be negative numbers
]]--

-- Local functions
------------------

-- Table deep copy

local function deep_copy(input)
	local output = {}
	local key, value
	for key, value in pairs(input) do
		if type(value) == 'table' then
			output[key] = deep_copy(value)
		else
			output[key] = value
		end
	end
	return output
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

--------------------------------------------------------------------------------
--- Font class

font_api.Font = {}

function font_api.Font:new(def)

	if type(def) ~= "table" then
		minetest.log("error", "Font definition must be a table.")
		return nil
	end
	
	if def.height == nil or def.height <= 0 then
		minetest.log("error", "Font definition must have a positive height.")
		return nil
	end

	if type(def.widths) ~= "table" then
		minetest.log("error", "Font definition must have a widths array.")
		return nil
	end

	if def.widths[0] == nil then
		minetest.log("error", 
			"Font must have a char with codepoint 0 (=unknown char).")
		return nil
	end

	local font = deep_copy(def)
	setmetatable(font, self)
	self.__index = self
	return font
end

--- Returns the width of a given char
-- @param char : codepoint of the char
-- @return Char width

function font_api.Font:get_char_width(char)
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

function font_api.Font:get_height(nb_of_lines)
	if nb_of_lines == nil then nb_of_lines = 1 end
	
	if nb_of_lines > 0 then
		return 
			(
				(self.height or 0) + 
				(self.margin_top or 0) +
				(self.margin_bottom or 0)
			) * nb_of_lines +
			(self.line_spacing or 0) * (nb_of_lines -1)
	else
		return nb_of_lines == 0 and 0 or nil
	end
end

--- Computes text width for a given text (ignores new lines)
-- @param line Line of text which the width will be computed.
-- @return Text width

function font_api.Font:get_width(line)

	local char
	local width = 0
    local pos = 1

	-- TODO: Use iterator
	while pos <= #line do
		char, pos = get_next_char(line, pos)
		width = width + self:get_char_width(char)
	end

	return width
end

--- Builds texture part for a text line
-- @param line Text line to be rendered
-- @param texturew Width of the texture (extra text is not rendered)
-- @param x Starting x position in texture
-- @param y Vertical position of the line in texture
-- @return Texture string

function font_api.Font:make_line_texture(line, texturew, x, y)
	local texture = ""
	local char
	local pos = 1

	-- TODO: Use iterator
	while pos <= #text do
		char, pos = get_next_char(line, pos)

		-- Replace chars with no texture by the NULL(0) char
		if self.widths[char] == nil 
or char == 88 --DEBUG
		then
            print(string.format("["..font_api.name
                                .."] Missing char %d (%04x)",char,char))
            char = 0
		end

		-- Add image only if it is visible (at least partly)
		if x + self.widths[char] >= 0 and x <= texturew then
			texture = texture..
				string.format(":%d,%d=font_%s_%04x.png",
				              x, y, self.name, char)
		end
		x = x + self.widths[char]
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

function font_api.Font:make_text_texture(text, texturew, textureh, maxlines,
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

		y = y + self:get_height() + (self.line_spacing or 0)
	end

	texture = string.format("[combine:%dx%d", texturew, textureh)..texture
	if color then texture = texture.."^[colorize:"..color end
	return texture
end

