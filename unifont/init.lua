--[[
  Unifont for Font API
  Copyright 2021 SyiMyuZya

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local widths = {}

for i = 0,0xd7ff do
	widths[i] = 16
end
for i = 0xe000,0xfffd do
	widths[i] = 16
end

local halfwidth = dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/halfwidth.lua")
for i, codepoint in ipairs(halfwidth) do
	widths[codepoint] = 8
end

local function get_glyph(codepoint)
	if codepoint == 0 or codepoint > 0xffff or widths[codepoint] == nil then
		codepoint = 0xfffd
	end
	local x = codepoint % 256
	local y = math.floor(codepoint / 256)
	return string.format("unifont_sheet.png^[sheet:256x256:%d,%d", x, y)
end

font_api.register_font(
	"unifont",
	{
		default = true,
		margintop = 2,
		marginbottom = 2,
		linespacing = -3,
		height = 16,
		widths = widths,
		getglyph = get_glyph,
	}
)
