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

minetest.register_craft({
	output = 'ontime_clocks:green_digital',
	recipe = {
		{'', 'dye:green', ''},
		{'default:glass', 'default:mese_crystal', 'default:glass'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:red_digital',
	recipe = {
		{'', 'dye:red', ''},
		{'default:glass', 'default:mese_crystal', 'default:glass'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:white',
	recipe = {
		{'default:steel_ingot', 'default:paper', 'default:steel_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_black',
	recipe = {
		{'default:steel_ingot', 'dye:black', 'default:steel_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_gold',
	recipe = {
		{'default:gold_ingot', '', 'default:gold_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_white',
	recipe = {
		{'default:steel_ingot', 'dye:white', 'default:steel_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})


