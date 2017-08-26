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
font_lib.font_height = 12
font_lib.font = {}

-- Local functions

local function get_next_char(text, pos)
	pos = pos + 1
	local char = text:sub(pos, pos):byte()
	if char >= 0x80 then
		if char == 0xc2 or char == 0xc3 then
			pos = pos + 1
			char = (char - 0xc2) * 0x40 + text:sub(pos, pos):byte()
		else
			char = 0
		end
	end
	if font_lib.font[char] == nil then char=0 end

	return char, pos
end

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

-- Computes line width for a given font height and text
-- @param text Text to be rendered
-- @return Rendered text width

function font_lib.get_line_width(text)
	local char
	local width = 0
    local p=0
 
	while p < #text do
		char, p = get_next_char(text, p)
		width = width + font_lib.font[char].width
	end

	return width
end

--- Builds texture part for a text line
-- @param text Text to be rendered
-- @param texturew Width of the texture (extra text is not rendered)
-- @param x Starting x position in texture
-- @param y Vertical position of the line in texture
-- @return Texture string

function font_lib.make_line_texture(text, texturew, x, y)
	local char
	local texture = ""
    local p=0
 
	while p < #text do
		char, p = get_next_char(text, p)

		-- Add image only if it is visible (at least partly)
		if x + font_lib.font[char].width >= 0 and x <= texturew then
			texture = texture..string.format(":%d,%d=%s", x, y, font_lib.font[char].filename)
		end
		x = x + font_lib.font[char].width

	end
	return texture
end

--- Builds texture for a multiline colored text
-- @param text Text to be rendered
-- @param texturew Width of the texture (extra text will be truncated)
-- @param textureh Height of the texture
-- @param maxlines Maximum number of lines
-- @param valign Vertical text align ("top" or "center")
-- @param color Color of the text
-- @return Texture string

function font_lib.make_multiline_texture(text, texturew, textureh, maxlines, valign, color)
	local texture = ""
	local lines = split_lines(text, maxlines)
	local y

	if valign == "top" then
		y = font_lib.font_height / 2 - 1
	else		
		y = (textureh - font_lib.font_height * #lines) / 2
	end

	for _, line in pairs(lines) do
		texture = texture..font_lib.make_line_texture(line, texturew,
			(texturew - font_lib.get_line_width(line)) / 2, y)
		y = y + font_lib.font_height
	end

	texture = string.format("[combine:%dx%d", texturew, textureh)..texture
	if color then texture = texture.."^[colorize:"..color end

	return texture
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
				text, def.size.x*def.resolution.x, def.size.y*def.resolution.y, 
				def.maxlines, def.valign, def.color)}, 
			visual_size = def.size
		})
	end
end

-- Populate fonts table

local filename
for char = 0,255 do
	filename = string.format("font_lib_%02x.png", char)
	local file=io.open(font_lib.path.."/textures/"..filename,"rb")
	if file~=nil then 
		-- Get png width, suposing png width is less than 256 (it is the case for all font textures)
		-- All font png are smaller than 256x256 --> read only last byte
		file:seek("set",19)
		local w = file:read(1)
		file:close()
		font_lib.font[char] = {filename=filename, width=w:byte()}
	end
end

