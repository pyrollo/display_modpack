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

local S = ontime_clocks.S

local function clock_on_construct(pos)
	local timer = minetest.get_node_timer(pos)
	timer:start(5)
	display_api.on_construct(pos)
end

local function clock_on_timer(pos)
	display_api.update_entities(pos)
	return true
end

minetest.register_lbm({
	name = "ontime_clocks:nodetimer_init",
	nodenames = {"group:ontime_clocks_tick"},
	run_at_every_load = false,
	action = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(5)
	end
})

local function register_clock(name, def)
	def.on_place = display_api.on_place
	def.on_construct = clock_on_construct
	def.on_destruct = display_api.on_destruct
	def.on_blast = display_api.on_blast
	def.on_rotate = display_api.on_rotate
	def.on_timer = clock_on_timer
	def.groups.ontime_clocks_tick = 1
	def.groups.display_api = 1

	minetest.register_node(name, def)
end

-- Green digital clock
register_clock("ontime_clocks:green_digital", {
	description = S("Green digital clock"),
	inventory_image = "ontime_clocks_green_digital_inventory.png",
	wield_image = "ontime_clocks_green_digital_inventory.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = {-0.5, -3/16, -7/16, -13/32, 7/32, 7/16},
		wall_bottom = {-7/16, -0.5, -3/16, 7/16, -13/32, 7/32},
		wall_top = {-7/16, 0.5, -7/32, 7/16, 13/32, 3/16}
	},
	tiles = {"ontime_clocks_digital.png"},
	groups = {oddly_breakable_by_hand=1, not_blocking_trains=1, handy = 1},
	_mcl_hardness = 0.8,
	_mcl_blast_resistance = 1,
	is_ground_content = false,
	display_entities = {
		["ontime_clocks:display"] = {
			depth = 13/32 - 0.01,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_digital_properties(
						"#040", "#0F0", ontime_clocks.get_h24(), ontime_clocks.get_m12()))
			end },
	},
})


-- Red digital clock
register_clock("ontime_clocks:red_digital", {
	description = S("Red digital clock"),
	inventory_image = "ontime_clocks_red_digital_inventory.png",
	wield_image = "ontime_clocks_red_digital_inventory.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_side = {-0.5, -3/16, -7/16, -13/32, 7/32, 7/16},
		wall_bottom = {-7/16, -0.5, -3/16, 7/16, -13/32, 7/32},
		wall_top = {-7/16, 0.5, -7/32, 7/16, 13/32, 3/16}
	},
	tiles = {"ontime_clocks_digital.png"},
	groups = {oddly_breakable_by_hand=1, not_blocking_trains=1, handy = 1},
	_mcl_hardness = 0.8,
	_mcl_blast_resistance = 1,
	is_ground_content = false,
	display_entities = {
		["ontime_clocks:display"] = {
			depth = 13/32 - 0.01,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_digital_properties(
						"#400", "#F00", ontime_clocks.get_h24(), ontime_clocks.get_m12()))
			end },
	},
})


register_clock("ontime_clocks:white", {
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
	groups = {oddly_breakable_by_hand=1, not_blocking_trains=1, handy = 1},
	_mcl_hardness = 0.8,
	_mcl_blast_resistance = 1,
	is_ground_content = false,
	display_entities = {
		["ontime_clocks:display"] = {
			depth = 6/16 - 0.01,
			on_display_update = function(pos, objref)
				objref:set_properties(
					ontime_clocks.get_needles_properties(
						"#000", 36, ontime_clocks.get_h12(), ontime_clocks.get_m12()))
			end },
	},
})

local function register_large_clock(name, label, color, size)
	local sstr = size .. "x" .. size -- Size string
	register_clock("ontime_clocks:" .. sstr .. "_clock_" .. name, {
		description = S("@1 frameless @2 clock", sstr, label),
		inventory_image = "ontime_clocks_large_clock_inventory.png^[colorize:" ..
			color .. "^ontime_clocks_" .. sstr .. "_clock_inventory.png",
		wield_image = "ontime_clocks_large_clock_inventory.png^[colorize:" .. color,
		paramtype = "light",
		paramtype2 = "wallmounted",
		drawtype = "nodebox",
		use_texture_alpha = "clip",
		node_box = {
			type = "wallmounted",
			wall_side = { -0.5, -7/16, -7/16, -15/32, 7/16, 7/16 },
			wall_bottom = { -7/16, -0.5, -7/16, 7/16, -15/32, 7/16 },
			wall_top = { -7/16, 0.5, -7/16, 7/16, 15/32, 7/16 }
		},
		tiles = {"ontime_clocks_" .. sstr .. "_center.png^[colorize:" .. color},
		groups = {oddly_breakable_by_hand = 1, not_blocking_trains = 1,	handy = 1},
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 1,
		is_ground_content = false,
		display_entities = {
			["ontime_clocks:hours_needle"] = {
				depth = 14/32,
				on_display_update = function(pos, objref)
					objref:set_properties({
						textures={"ontime_clocks_" .. sstr .. "_needle_hours.png^[colorize:" .. color},
						visual_size = {x=1, y=size},
					})
					objref:get_luaentity()["rotation"] = {
						z = math.floor(minetest.get_timeofday() * 24) / 6 * math.pi
					}
				end
		    },
			["ontime_clocks:minutes_needle"] = {
				depth = 13/32,
				on_display_update = function(pos, objref)
					objref:set_properties({
						textures={"ontime_clocks_" .. sstr .. "_needle_minutes.png^[colorize:" .. color},
						visual_size = {x=1, y=size},
					})
					objref:get_luaentity()["rotation"] = {
						z = math.floor(minetest.get_timeofday() * 288) / 6 * math.pi
					}
				end
		    },
		},
	})
end

local models = {
	{ name = "gold", label = S("gold"), color = "#FF0" },
	{ name = "black", label = S("black"), color = "#000" },
	{ name = "white", label = S("white"), color = "#FFF" },
}

for _, model in ipairs(models) do
	-- Frameless clock
	register_clock("ontime_clocks:frameless_" .. model.name, {
		description = S("Frameless @1 clock", model.label),
		inventory_image = "ontime_clocks_frameless_inventory.png^[colorize:" .. model.color,
		wield_image = "ontime_clocks_frameless_inventory.png^[colorize:" .. model.color,
		paramtype = "light",
		paramtype2 = "wallmounted",
		drawtype = "nodebox",
		use_texture_alpha = "clip",
		node_box = {
			type = "wallmounted",
			wall_side = { -0.5, -7/16, -7/16, -0.45, 7/16, 7/16 },
			wall_bottom = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			wall_top = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }
		},
		tiles = {"ontime_clocks_frameless.png^[colorize:" .. model.color},
		groups = { oddly_breakable_by_hand=1, not_blocking_trains=1, handy = 1},
		_mcl_hardness = 0.8,
		_mcl_blast_resistance = 1,
		is_ground_content = false,
		display_entities = {
			["ontime_clocks:display"] = {
				depth = 7/16,
				on_display_update = function(pos, objref)
					objref:set_properties(
						ontime_clocks.get_needles_properties(
							model.color, 48,
							ontime_clocks.get_h12(),
							ontime_clocks.get_m12()
						)
					)
				end },
		},
	})

	-- 3x3 large clock
	register_large_clock(model.name, model.label, model.color, 3)

    -- 5x5 large clock
	register_large_clock(model.name, model.label, model.color, 5)
end

