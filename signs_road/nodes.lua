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

local S = signs_road.intllib

local models = {
	blue_street_sign = {
		depth = 1/16,
		width = 14/16,
		height = 12/16,
		entity_fields = {
			size = { x = 14/16, y = 10/16 },
			maxlines = 3,
			color = "#fff",
		},
		node_fields = {
			description = S("Blue street sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_blue_street.png" },
			inventory_image = "signs_road_blue_street.png",
		},
	},
	large_street_sign = {
		depth = 1/16,
		width = 64/16,
		height = 12/16,
		entity_fields = {
			maxlines = 1,
			color = "#000",
		},
		node_fields = {
		   visual_scale = 1,
			description = S("Large banner"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_large_white.png" },
			inventory_image = "signs_road_white.png",
		},
	},
	red_street_sign = {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = { x = 1, y = 4/16 },
			maxlines = 1,
			color = "#000",
		},
		node_fields = {
			description = S("Red and white town sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_red_white.png" },
			inventory_image="signs_road_red_white.png",
		},
	},
	white_sign = {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = { x = 1, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("White street sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_white.png" },
			inventory_image = "signs_road_white.png",
		},
	},
	blue_sign = {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = { x = 1, y = 6/16 },
			maxlines = 2,
			color = "#fff",
		},
		node_fields = {
			description = S("Blue road sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_blue.png" },
			inventory_image = "signs_road_blue.png",
		},
	},
	green_sign = {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = { x = 1, y = 6/16 },
			maxlines = 2,
			color = "#fff",
		},
		node_fields = {
			description = S("Green road sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_green.png" },
			inventory_image = "signs_road_green.png",
		},
	},
	yellow_sign = {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = { x = 1, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("Yellow road sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_yellow.png" },
			inventory_image="signs_road_yellow.png",
		},
	},
	red_sign = {
		depth = 1/16,
		width = 1,
		height = 7/16,
		entity_fields = {
			size = { x = 1, y = 6/16 },
			maxlines = 2,
			color = "#fff",
		},
		node_fields = {
			description = S("Red road sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_red.png" },
			inventory_image = "signs_road_red.png",
		},
	},
	black_right_sign = {
		depth = 1/32,
		width = 1,
		height = 0.5,
		entity_fields = {
			aspect_ratio = 3/4,
			size = { x = 1, y = 3/16 },
			maxlines = 1,
			color = "#000",
		},
		node_fields = {
			description = S("Black direction sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_black_dir_right.png" },
			inventory_image = "signs_road_black_dir_inventory.png",
			signs_other_dir = "signs_road:black_left_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
		},
	},
	black_left_sign = {
		depth = 1/32,
		width = 1,
		height = 0.5,
		entity_fields = {
			aspect_ratio = 3/4,
			size = { x = 1, y = 3/16 },
			maxlines = 1,
			color = "#000",
		},
		node_fields = {
			description = S("Black direction sign"),
			tiles = { "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_sides.png",
			          "signs_road_sides.png", "signs_road_black_dir_left.png" },
			inventory_image = "signs_road_black_dir_inventory.png",
			signs_other_dir = "signs_road:black_right_sign",
			groups = { not_in_creative_inventory = 1 },
			drop = "signs_road:black_right_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
		},
	},
	white_right_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = -3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("White direction sign"),
			tiles = { "signs_road_white_direction.png" },
			inventory_image = "signs_road_white_dir_inventory.png",
			signs_other_dir = "signs_road:white_left_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_right.obj",
			selection_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
		},
	},
	white_left_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = 3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("White direction sign"),
			tiles = { "signs_road_white_direction.png" },
			inventory_image = "signs_road_white_dir_inventory.png",
			signs_other_dir = "signs_road:white_right_sign",
			on_place=signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_left.obj",
			selection_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			groups = { not_in_creative_inventory = 1 },
			drop = "signs_road:white_right_sign",
		},
	},
	blue_right_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = -3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#fff",
		},
		node_fields = {
			description = S("Blue direction sign"),
			tiles = { "signs_road_blue_direction.png" },
			inventory_image = "signs_road_blue_dir_inventory.png",
			signs_other_dir = "signs_road:blue_left_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_right.obj",
			selection_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
		},
	},
	blue_left_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = 3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color="#fff",
		},
		node_fields = {
			description = S("Blue direction sign"),
			tiles = { "signs_road_blue_direction.png" },
			inventory_image = "signs_road_blue_dir_inventory.png",
			signs_other_dir = "signs_road:blue_right_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_left.obj",
			selection_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			groups = { not_in_creative_inventory = 1 },
			drop = "signs_road:blue_right_sign",
		},
	},
	green_right_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = -3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#fff",
		},
		node_fields = {
			description = S("Green direction sign"),
			tiles = { "signs_road_green_direction.png" },
			inventory_image = "signs_road_green_dir_inventory.png",
			signs_other_dir = "signs_road:green_left_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_right.obj",
			selection_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
		},
	},
	green_left_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = 3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color="#fff",
		},
		node_fields = {
			description = S("Green direction sign"),
			tiles = { "signs_road_green_direction.png" },
			inventory_image = "signs_road_green_dir_inventory.png",
			signs_other_dir = "signs_road:green_right_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_left.obj",
			selection_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			groups = { not_in_creative_inventory = 1 },
			drop = "signs_road:green_right_sign",
		},
	},
	yellow_right_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = -3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("Yellow direction sign"),
			tiles = { "signs_road_yellow_direction.png" },
			inventory_image = "signs_road_yellow_dir_inventory.png",
			signs_other_dir = "signs_road:yellow_left_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_right.obj",
			selection_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
		},
	},
	yellow_left_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = 3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("Yellow direction sign"),
			tiles = { "signs_road_yellow_direction.png" },
			inventory_image = "signs_road_yellow_dir_inventory.png",
			signs_other_dir = "signs_road:yellow_right_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_left.obj",
			selection_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			groups = { not_in_creative_inventory = 1 },
			drop = "signs_road:yellow_right_sign",
		},
	},
	red_right_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = -3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#fff",
		},
		node_fields = {
			description = S("Red direction sign"),
			tiles = { "signs_road_red_direction.png" },
			inventory_image = "signs_road_red_dir_inventory.png",
			signs_other_dir = "signs_road:red_left_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_right.obj",
			selection_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -0.5, -7/32, 0.5, 7/16, 7/32, 7/16 } },
		},
	},
	red_left_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			right = 3/32,
			size = { x = 12/16, y = 6/16 },
			maxlines = 2,
			color = "#fff",
		},
		node_fields = {
			description = S("Red direction sign"),
			tiles = { "signs_road_red_direction.png" },
			inventory_image = "signs_road_red_dir_inventory.png",
			signs_other_dir = "signs_road:red_right_sign",
			on_place = signs_api.on_place_direction,
			on_rightclick = signs_api.on_right_click_direction,
			drawtype = "mesh",
			mesh = "signs_dir_left.obj",
			selection_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			collision_box = { type = "fixed", fixed = { -7/16, -7/32, 0.5, 0.5, 7/32, 7/16 } },
			groups = { not_in_creative_inventory = 1 },
			drop = "signs_road:red_right_sign",
		},
	},
}

-- Node registration
for name, model in pairs(models)
do
	signs_api.register_sign("signs_road", name, model)
end
