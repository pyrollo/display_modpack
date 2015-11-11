-- Poster specific formspec
local function on_rightclick_poster(pos, node, player)
	local formspec
	local meta = minetest.get_meta(pos)
	if not minetest.is_protected(pos, player:get_player_name()) then
		formspec =
			"size[6.5,7.5]"..
			"field[0.5,0.7;6,1;display_text;Title;"..minetest.formspec_escape(meta:get_string("display_text")).."]"..
			"textarea[0.5,1.7;6,6;text;Text;"..minetest.formspec_escape(meta:get_string("text")).."]"..
			"button_exit[2,7;2,1;ok;Write]"
		minetest.show_formspec(player:get_player_name(),
			"signs:poster@"..minetest.pos_to_string(pos),
			formspec)
	else
		formspec = "size[8,9]"..
			"size[6.5,7.5]"..
			"label[0.5,0;"..minetest.formspec_escape(meta:get_string("display_text")).."]"..
			"textarea[0.5,1;6,7;;"..minetest.formspec_escape(meta:get_string("text"))..";]"..
			"bgcolor[#111]"..
			"button_exit[2,7;2,1;ok;Close]"
		minetest.show_formspec(player:get_player_name(),
			"",
			formspec)
	end

end

-- Poster specific on_receive_fields callback
local function on_receive_fields_poster(pos, formname, fields, player)
	local meta = minetest.get_meta(pos)
	if not minetest.is_protected(pos, player:get_player_name()) then
		if fields and fields.ok then
			meta:set_string("display_text", fields.display_text)
			meta:set_string("text", fields.text)
			meta:set_string("infotext", "\""..fields.display_text
					.."\"\n(right-click to read more text)")
			display_lib.update_entities(pos)
		end
	end
end

signs.sign_models = {
	blue_street={
		depth=1/16,
		width=14/16,
		height=12/16,
		color="#fff",
		maxlines = 3,
		xscale = 1/144,
		yscale = 1/64,
		fields = {
			description="Blue street sign",
			tiles={"signs_blue_street.png"},
			inventory_image="signs_blue_street_inventory.png",
		},
	},
	green_street={
		depth=1/32,
		width=1,
		height=6/16,
		color="#fff",
		maxlines = 1,
		xscale = 1/96,
		yscale = 1/64,
		fields = {
			description="Green street sign",
			tiles={"signs_green_street.png"},
			inventory_image="signs_green_street_inventory.png",
		},
	},
	wooden_right={
		depth=1/16,
		width=14/16,
		height=7/16,
		color="#000",
		maxlines = 2,
		xscale = 1/112,
		yscale = 1/64,
		fields = {
			description="Wooden direction sign",
			tiles={"signs_wooden_right.png"},
			inventory_image="signs_wooden_inventory.png",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,

		},
	},
	wooden_left={
		depth=1/16,
		width=14/16,
		height=7/16,
		color="#000",
		maxlines = 2,
		xscale = 1/112,
		yscale = 1/64,
		fields = {
			description="Wooden direction sign",
			tiles={"signs_wooden_left.png"},
			inventory_image="signs_wooden_inventory.png",
			groups={choppy=1,oddly_breakable_by_hand=1,not_in_creative_inventory=1},
			drop="signs:wooden_right",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,
		},
	},
	black_right={
		depth=1/32,
		width=1,
		height=0.5,
		color="#000",
		maxlines = 1,
		xscale = 1/96,
		yscale = 1/64,
		fields = {
			description="Black direction sign",
			tiles={"signs_black_right.png"},
			inventory_image="signs_black_inventory.png",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,
		},
	},
	black_left={
		depth=1/32,
		width=1,
		height=0.5,
		color="#000",
		maxlines = 1,
		xscale = 1/96,
		yscale = 1/64,
		fields = {
			description="Black direction sign",
			tiles={"signs_black_left.png"},
			inventory_image="signs_black_inventory.png",
			groups={choppy=1,oddly_breakable_by_hand=1,not_in_creative_inventory=1},
			drop="signs:black_right",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,
		},
	},
	poster={
		depth=1/32,
		width=26/32,
		height=30/32,
		color="#000",
		valing="top",
		maxlines = 1,
		xscale = 1/144,
		yscale = 1/64,
		fields = {
			description="Poster",
			tiles={"signs_poster.png"},
			inventory_image="signs_poster_inventory.png",
			on_construct=display_lib.on_construct,
			on_rightclick=on_rightclick_poster,
			on_receive_fields=on_receive_fields_poster,
		},
	},
}

display_lib.register_display_entity("signs:text")

for model_name, model in pairs(signs.sign_models)
do
	local fields = {
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "wallmounted",
		drawtype = "nodebox",
		node_box = {
			type = "wallmounted",
			wall_side = {-0.5, -model.height/2, -model.width/2, 
					     -0.5 + model.depth, model.height/2, model.width/2},
			wall_bottom = {-model.width/2, -0.5, -model.height/2,
						   model.width/2, -0.5 + model.depth, model.height/2},
			wall_top = {-model.width/2, 0.5, -model.height/2,
						   model.width/2, 0.5 - model.depth, model.height/2}, 
		},
		groups = {choppy=1,oddly_breakable_by_hand=1},
		sign_model = model_name,
		display_entities = { 
			["signs:text"] = {
					depth = model.depth-0.499,
					on_display_update = signs.on_display_update },
		},
		on_place = display_lib.on_place,
		on_construct = 	function(pos)
							signs.set_formspec(pos)
							display_lib.on_construct(pos)
						end,
		on_destruct = display_lib.on_destruct,
		on_rotate = display_lib.on_rotate,
		on_receive_fields = signs.on_receive_fields,
	}

	for key, value in pairs(model.fields) do
		fields[key] = value
	end

	if not fields.wield_image then fields.wield_image = fields.inventory_image end

	minetest.register_node("signs:"..model_name, fields)
end

