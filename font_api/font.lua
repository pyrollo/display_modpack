--[[
	font_api mod for Minetest - Library creating textures with fonts and text
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
	elseif bytes == 2 and str:byte(2) ~= nil then
		return (str:byte(1) - 0xC2) * 0x40
			+ str:byte(2)
	elseif bytes == 3 and str:byte(2) ~= nil and str:byte(3) ~= nil then
		return (str:byte(1) - 0xE0) * 0x1000
			+ str:byte(2) % 0x40 * 0x40
			+ str:byte(3) % 0x40
	elseif bytes == 4 and str:byte(2) ~= nil and str:byte(3) ~= nil
		and str:byte(4) ~= nil then -- Not tested
		return (str:byte(1) - 0xF0) * 0x40000
			+ str:byte(2) % 0x40 * 0x1000
			+ str:byte(3) % 0x40 * 0x40
			+ str:byte(4) % 0x40
	end
end

--------------------------------------------------------------------------------
--- Font class

local Font = {}
Font.__index = Font
font_api.Font = Font

function Font:new(def)

	if type(def) ~= "table" then
		minetest.log("error",
			"[font_api] Font definition must be a table.")
		return nil
	end

	local font = table.copy(def)

	-- Version 1 is with one texture per glyph
	if font.version == nil or font.version == 1 then
		if font.height == nil or font.height <= 0 then
			minetest.log("error",
				"[font_api] Font definition must have a positive height.")
			return nil
		end

		if type(font.widths) ~= "table" then
			minetest.log("error",
				"[font_api] Font definition must have a `widths` array.")
			return nil
		end

		-- Kind of convert to version 2

		font.glyphs = {}
		for codepoint, width in pairs(font.widths) do
			font.glyphs[codepoint] = { width, codepoint }
		end
		font.widths = nil

		font.glyphs_height = font.height
		font.height = nil
	end

	-- Version 2 is with one only texture for all glyphs, using `[sheet` textures
	if font.version == 2 then
		if type(font.glyphs) ~= "table" then
			minetest.log("error",
				"[font_api] Font definition must have a `glyphs` array.")
			return nil
		end

		if font.texture_height == nil or font.texture_height <= 0 then
			minetest.log("error",
				"[font_api] Font definition must have a positive `texture_height`.")
			return nil
		end

		if font.glyphs_height == nil or font.glyphs_height <= 0 then
			minetest.log("error",
				"[font_api] Font definition must have a positive `glyphs_height`.")
			return nil
		end

		font.vertical_number_of_tiles = math.floor(font.texture_height / font.glyphs_height)
	end

	if font.glyphs[0] == nil then
		minetest.log("error",
			"[font_api] Font must have a char with codepoint 0 (=unknown char).")
		return nil
	end

	if self.charspacing == nil then
		self.charspacing = 0
	end

    setmetatable(font, self)

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

	if codepoint == nil then
		minetest.log("warning",
			"[font_api] Encountered a non UTF char, not displaying text.")
		return nil, ''
	end

	-- Fallback mechanism
	if self.glyphs[codepoint] == nil then
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

function Font:get_char_width(codepoint)
	-- [1] is char width
	return (self.glyphs[codepoint] or self.glyphs[0])[1] + self.charspacing
end

--- Returns texture for a given glyph
-- @param glyph: table representing the glyph
-- @return Texture

function Font:get_glyph_texture(glyph)
	if #glyph == 4 then
		-- Actual version with one texture for all glyphs
		return string.format("font_%s.png^[sheet:%dx%d:%d,%d",
			self.name, glyph[2], self.vertical_number_of_tiles, glyph[3], glyph[4])
	end
	if #glyph == 2 then
		-- Former version with one texture per glyph
		return string.format("font_%s_%04x.png",
			self.name, glyph[2])		
	end
	-- Case of invisible chars like space (no need to add any texture)
	return ""
end

--- Text height for multiline text including margins and line spacing
-- @param nb_of_lines : number of text lines (default 1)
-- @return Text height

function Font:get_height(nb_of_lines)
	if nb_of_lines == nil then nb_of_lines = 1 end

	if nb_of_lines > 0 then
		return
			(
				self.glyphs_height +
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
		if codepoint == nil then return 0 end -- UTF Error
		width = width + self:get_char_width(codepoint)
	end

	return width
end

--- Legacy make_text_texture method (replaced by "render" - Dec 2018)

function Font:make_text_texture(text, texturew, textureh, maxlines,
		halign, valign, color)
		return self:render(text, texturew, textureh, {
			lines = maxlines,
			valign = valign,
			halign = halign,
			color = color
		})
end

--- Render text with the font in a view
-- @param text Text to be rendered
-- @param width Width (in pixels) of the texture (extra text will be truncated)
-- @param height Height (in pixels) of the texture (extra text will be truncated)
-- @param style Style of the rendering:
--		- lines: maximum number of text lines (if text is limited)
--		- halign: horizontal align ("left"/"center"/"right")
--		- valign: vertical align ("top"/"center"/"bottom")
--		- color: color of the text ("#rrggbb")
-- @return Texture string

function Font:render(text, width, height, style)
	style = style or {}

	-- Split text into lines (and limit to style.lines # of lines)
	local lines = {}
	local pos = 1
	local found, line
	repeat
		found = string.find(text, "\n", pos) or (#text + 1)
		line = string.sub(text, pos, found - 1)
		lines[#lines + 1] = { text = line, width = self:get_width(line) }
		pos = found + 1
	until (style.lines and (#lines >= style.lines)) or (pos > (#text + 1))

	if not #lines then
		return ""
	end

	local x, y, codepoint
	local texture = ""
	local text_height = self:get_height(#lines)

	if style.valign == "top" then
		y = 0
	elseif style.valign == "bottom" then
		y = height - text_height
	else
		y = (height - text_height) / 2
	end

	y = y + (self.margintop or 0)

	for _, l in pairs(lines) do
		if style.halign == "left" then
			x = 0
		elseif style.halign == "right" then
			x = width - l.width
		else
			x = (width - l.width) / 2
		end

		while l.text ~= '' do
			codepoint, l.text = self:get_next_char(l.text)
			if codepoint == nil then return '' end -- UTF Error

			local glyph = self.glyphs[codepoint]

			-- Add image only if it is visible (at least partly)
			if x + glyph[1] + self.charspacing >= 0 and x <= width then
				local glyph_texture = self:get_glyph_texture(glyph):gsub("[\\^:]", "\\%0")
				if glyph_texture ~= '' then
					texture = string.format("%s:%d,%d=%s", texture, x, y, glyph_texture)
				end
			end
			x = x + glyph[1] + self.charspacing
		end

		y = y + self:get_height() + (self.linespacing or 0)
	end

	texture = string.format("[combine:%dx%d%s", width, height, texture)
	if style.color then
		texture = texture.."^[colorize:"..style.color
	end
	print(texture)
	return texture
end
