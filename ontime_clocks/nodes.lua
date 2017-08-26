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

local S = ontime_clocks.intllib

-- Green digital clock
minetest.register_node("ontime_clocks:green_digital", {
	description = S("Green digital clock"),
	inventory_image = "ontime_clocks_green_digital_inventory.png",
	wield_image = "ontime_clocks_green_digital_inventory.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -3/16, -7/16, -13/32, 7/32, 7/16 },
		wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },    
		wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } 
	},
	tiles = {"ontime_clocks_digital.png"},
	groups = {oddly_breakable_by_hand=1},
	display_entities = {
		["ontime_clocks:display"] = {
			depth = 13/32 - 0.01,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_digital_properties(
						"#040", "#0F0", ontime_clocks.get_h24(), ontime_clocks.get_m12()))
			end },
	},
	on_place = display_lib.on_place,
	on_construct = display_lib.on_construct,
	on_destruct = display_lib.on_destruct,
	on_rotate = display_lib.on_rotate,
})

minetest.register_abm({
	nodenames = {"ontime_clocks:green_digital"},
	interval = 5,
	chance = 1,
	action = display_lib.update_entities,
})

-- Red digital clock
minetest.register_node("ontime_clocks:red_digital", {
	description = S("Red digital clock"),
	inventory_image = "ontime_clocks_red_digital_inventory.png",
	wield_image = "ontime_clocks_red_digital_inventory.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -3/16, -7/16, -13/32, 7/32, 7/16 },
		wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },    
		wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } 
	},
	tiles = {"ontime_clocks_digital.png"},
	groups = {oddly_breakable_by_hand=1},
	display_entities = {
		["ontime_clocks:display"] = {
			depth = 13/32 - 0.01,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_digital_properties(
						"#400", "#F00", ontime_clocks.get_h24(), ontime_clocks.get_m12()))
			end },
	},
	on_place = display_lib.on_place,
	on_construct = display_lib.on_construct,
	on_destruct = display_lib.on_destruct,
	on_rotate = display_lib.on_rotate,
})

minetest.register_abm({
	nodenames = {"ontime_clocks:red_digital"},
	interval = 5,
	chance = 1,
	action = display_lib.update_entities,
})


minetest.register_node("ontime_clocks:white", {
	description = S("White clock"),
	inventory_image = "ontime_clocks_white_inventory.png",
	wield_image = "ontime_clocks_white_inventory.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -7/16, -7/16, -6/16, 7/16, 7/16},
		wall_bottom = { -7/16, -0.5, -7/16, 7/16, -7/16, 7/16},    
		wall_top = { -7/16, 0.5, -7/16, 7/16, 7/16, 7/16},    
	},
	tiles = {"ontime_clocks_white.png"},
	groups = {choppy=1,oddly_breakable_by_hand=1},
	display_entities = { 
		["ontime_clocks:display"] = {
			depth = 6/16 - 0.01,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_needles_properties(
						"#000", 36, ontime_clocks.get_h12(), ontime_clocks.get_m12()))
			end },
	},
	on_place = display_lib.on_place,
	on_construct = display_lib.on_construct,
	on_destruct = display_lib.on_destruct,
	on_rotate = display_lib.on_rotate,
})

minetest.register_abm({
	nodenames = {"ontime_clocks:white"},
	interval = 5,
	chance = 1,
	action = display_lib.update_entities,
})

minetest.register_node("ontime_clocks:frameless_black", {
	description = S("Frameless clock"),
	inventory_image = "ontime_clocks_frameless_inventory.png",
	wield_image = "ontime_clocks_frameless_inventory.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -7/16, -7/16, -0.45, 7/16, 7/16 },
		wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },    
		wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } 
	},
	tiles = {"ontime_clocks_frameless.png"},
	groups = {choppy=1,oddly_breakable_by_hand=1},
	display_entities = { 
		["ontime_clocks:display"] = {
			depth = 7/16,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_needles_properties(
						"#000", 48, ontime_clocks.get_h12(), ontime_clocks.get_m12()))
			end },
	},
	on_place = display_lib.on_place,
	on_construct = display_lib.on_construct,
	on_destruct = display_lib.on_destruct,
	on_rotate = display_lib.on_rotate,
})

minetest.register_abm({
	nodenames = {"ontime_clocks:frameless_black"},
	interval = 5,
	chance = 1,
	action = display_lib.update_entities,
})

minetest.register_node("ontime_clocks:frameless_gold", {
	description = S("Frameless gold clock"),
	inventory_image = "ontime_clocks_frameless_inventory.png^[colorize:#FF0",
	wield_image = "ontime_clocks_frameless_inventory.png^[colorize:#FF0",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -7/16, -7/16, -0.45, 7/16, 7/16 },
		wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },    
		wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } 
	},
	tiles = {"ontime_clocks_frameless.png^[colorize:#FF0"},
	groups = {choppy=1,oddly_breakable_by_hand=1},
	display_entities = { 
		["ontime_clocks:display"] = {
			depth = 7/16,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_needles_properties(
						"#FF0", 48, ontime_clocks.get_h12(), ontime_clocks.get_m12()))
			end },
	},
	on_place = display_lib.on_place,
	on_construct = display_lib.on_construct,
	on_destruct = display_lib.on_destruct,
	on_rotate = display_lib.on_rotate,
})

minetest.register_abm({
	nodenames = {"ontime_clocks:frameless_gold"},
	interval = 5,
	chance = 1,
	action = display_lib.update_entities,
})

minetest.register_node("ontime_clocks:frameless_white", {
	description = S("Frameless white clock"),
	inventory_image = "ontime_clocks_frameless_inventory.png^[colorize:#FFF",
	wield_image = "ontime_clocks_frameless_inventory.png^[colorize:#FFF",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -7/16, -7/16, -0.45, 7/16, 7/16 },
		wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },    
		wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 } 
	},
	tiles = {"ontime_clocks_frameless.png^[colorize:#FFF"},
	groups = {choppy=1,oddly_breakable_by_hand=1},
	display_entities = { 
		["ontime_clocks:display"] = {
			depth = 7/16,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_needles_properties(
						"#FFF", 48, ontime_clocks.get_h12(), ontime_clocks.get_m12()))
			end },
	},
	on_place = display_lib.on_place,
	on_construct = display_lib.on_construct,
	on_destruct = display_lib.on_destruct,
	on_rotate = display_lib.on_rotate,
})

minetest.register_abm({
	nodenames = {"ontime_clocks:frameless_white"},
	interval = 5,
	chance = 1,
	action = display_lib.update_entities,
})
