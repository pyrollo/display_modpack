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

-- Text entity for all signs
display_lib.register_display_entity("signs:text")

-- Sign models and registration
local models = {
	wooden_right={
		depth=1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			resolution = { x = 112, y = 64 },
			maxlines = 2,
			color="#000",
		},
		node_fields = {
			description="Wooden direction sign",
			tiles={"signs_wooden_right.png"},
			inventory_image="signs_wooden_inventory.png",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,

		},
	},
	wooden_left={
		depth=1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
			resolution = { x = 112, y = 64 },
			maxlines = 2,
			color="#000",
		},
		node_fields = {
			description="Wooden direction sign",
			tiles={"signs_wooden_left.png"},
			inventory_image="signs_wooden_inventory.png",
			groups={choppy=1,oddly_breakable_by_hand=1,not_in_creative_inventory=1},
			drop="signs:wooden_right",
			on_place=signs.on_place_direction,
			on_rotate=signs.on_rotate_direction,
		},
	},
	poster={
		depth=1/32,
		width = 26/32,
		height = 30/32,
		entity_fields = {
			resolution = { x = 144, y = 64 },
			maxlines = 1,
			color="#000",
			valign="top",
		},
		node_fields = {
			description="Poster",
			tiles={"signs_poster.png"},
			inventory_image="signs_poster_inventory.png",
			on_construct=display_lib.on_construct,
			on_rightclick=on_rightclick_poster,
			on_receive_fields=on_receive_fields_poster,
		},
	},
}


for name, model in pairs(models)
do
	signs.register_sign("signs", name, model)
end

-- Override default sign
signs.register_sign(":default", "sign_wall", {
		depth = 1/16,
		width = 14/16,
		height = 10/16,
		entity_fields = {
			size = { x = 12/16, y = 8/16 },
			resolution = { x = 144, y = 64 },
			maxlines = 3,
			color="#000",
		},
		node_fields = {
			description="Sign",
			tiles={"signs_default.png"},
			inventory_image="signs_default_inventory.png",
		},
	})

