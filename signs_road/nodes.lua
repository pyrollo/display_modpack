
local models = {
	blue_street={
		depth = 1/16,
		width = 14/16,
		height = 12/16,
		entity_fields = {
			resolution = { x = 144, y = 64 },
			maxlines = 3,
			color="#fff",
		},
		node_fields = {
			description="Blue street sign",
			tiles={"signs_blue_street.png"},
			inventory_image="signs_blue_street_inventory.png",
		},
	},
	green_street={
		depth=1/32,
		width = 1,
		height = 6/16,
		entity_fields = {
			resolution = { x = 96, y = 64 },
			maxlines = 1,
			color="#fff",
		},
		node_fields = {
			description="Green street sign",
			tiles={"signs_green_street.png"},
			inventory_image="signs_green_street_inventory.png",
		},
	},
	black_right={
		depth=1/32,
		width = 1,
		height = 0.5,
		entity_fields = {
			resolution = { x = 96, y = 64 },
			maxlines = 1,
			color="#000",
		},
		node_fields = {
			description="Black direction sign",
			tiles={"signs_black_right.png"},
			inventory_image="signs_black_inventory.png",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,
		},
	},
	black_left={
		depth=1/32,
		width = 1,
		height = 0.5,
		entity_fields = {
			resolution = { x = 96, y = 64 },
			maxlines = 1,
			color="#000",
		},
		node_fields = {
			description="Black direction sign",
			tiles={"signs_black_left.png"},
			inventory_image="signs_black_inventory.png",
			groups={choppy=1,oddly_breakable_by_hand=1,not_in_creative_inventory=1},
			drop="signs:black_right",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,
		},
	},
}


for name, model in pairs(models)
do
	signs.register_sign("signs_road", name, model)
end
