--[[
    signs_road mod for Minetest - Various road signs with text displayed
    on.
    (c) Pierre-Yves Rollo

    This file is part of signs_road.

    signs_road is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs_road is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs_road.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Standard rectangle signs

minetest.register_craft({
	output = 'signs_road:white_sign 2',
	recipe = {
		{'dye:white', 'dye:black', ''},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:blue_sign 2',
	recipe = {
		{'dye:blue', 'dye:white', ''},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:green_sign 2',
	recipe = {
		{'dye:green', 'dye:white', ''},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:yellow_sign 2',
	recipe = {
		{'dye:yellow', 'dye:black', ''},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:red_sign 2',
	recipe = {
		{'dye:red', 'dye:white', ''},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

-- Standard direction signs

minetest.register_craft({
	output = 'signs_road:black_right_sign 2',
	recipe = {
		{'dye:black', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:white_right_sign 2',
	recipe = {
		{'dye:white', 'dye:black', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:blue_right_sign 2',
	recipe = {
		{'dye:blue', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:green_right_sign 2',
	recipe = {
		{'dye:green', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:yellow_right_sign 2',
	recipe = {
		{'dye:yellow', 'dye:black', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:red_right_sign 2',
	recipe = {
		{'dye:red', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

-- Transform Rectangle <-> Direction

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:white_right_sign',
	recipe = {'signs_road:white_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:white_sign',
	recipe = {'signs_road:white_right_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:blue_right_sign',
	recipe = {'signs_road:blue_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:blue_sign',
	recipe = {'signs_road:blue_right_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:green_right_sign',
	recipe = {'signs_road:green_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:green_sign',
	recipe = {'signs_road:green_right_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:yellow_right_sign',
	recipe = {'signs_road:yellow_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:yellow_sign',
	recipe = {'signs_road:yellow_right_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:red_right_sign',
	recipe = {'signs_road:red_sign'},
})

minetest.register_craft({
	type = 'shapeless', output = 'signs_road:red_sign',
	recipe = {'signs_road:red_right_sign'},
})

-- Various signs

minetest.register_craft({
	output = 'signs_road:blue_street_sign 4',
	recipe = {
		{'dye:blue', 'dye:white', 'dye:blue'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'signs_road:red_street_sign 2',
	recipe = {
		{'dye:white', 'dye:red', 'dye:black'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
      type = "shapeless",
      output = 'signs_road:large_street_sign',
      recipe = {'signs_road:white_street_sign', 'signs_road:white_street_sign', 'signs_road:white_street_sign', 'signs_road:white_street_sign'},
})
