--[[
    ontime_clocks mod for Minetest - Clock nodes displaying ingame time
    (c) Pierre-Yves Rollo

    This file is part of ontime_clocks.

    ontime_clocks is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ontime_clocks is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ontime_clocks.  If not, see <http://www.gnu.org/licenses/>.
--]]

local mat = xcompat.materials

minetest.register_craft({
	output = 'ontime_clocks:green_digital',
	recipe = {
		{'', mat.dye_green, ''},
		{mat.glass, mat.mese_crystal, mat.glass},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:red_digital',
	recipe = {
		{'', mat.dye_red, ''},
		{mat.glass, mat.mese_crystal, mat.glass},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:white',
	recipe = {
		{mat.steel_ingot, mat.paper, mat.steel_ingot},
		{'', mat.mese_crystal, ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_black',
	recipe = {
		{mat.steel_ingot, mat.dye_black, mat.steel_ingot},
		{'', mat.mese_crystal, ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_gold',
	recipe = {
		{mat.gold_ingot, '', mat.gold_ingot},
		{'', mat.mese_crystal, ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_white',
	recipe = {
		{mat.steel_ingot, mat.dye_white, mat.steel_ingot},
		{'', mat.mese_crystal, ''},
		{'', '', ''},
	}
})


