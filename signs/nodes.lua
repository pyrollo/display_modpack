--[[
    signs mod for Minetest - Various signs with text displayed on
    (c) Pierre-Yves Rollo

    This file is part of signs.

    signs is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs.  If not, see <http://www.gnu.org/licenses/>.
--]]

local S = signs.intllib
local F = function(...) return minetest.formspec_escape(S(...)) end

-- Poster specific formspec
local function display_poster(pos, node, player)
	local formspec
	local meta = minetest.get_meta(pos)
	local def = minetest.registered_nodes[node.name].display_entities["signs:display_text"]

	-- Title texture
	local titletexture = font_lib.make_multiline_texture(
	  def.font_name, meta:get_string("display_text"),
	  116, 12, def.maxlines, def.valign, def.color)

	formspec =
		"size[7,9]"..
		"background[0,0;7,9;signs_poster_formspec.png]"..
		"image[0,0;8.4,1.5;"..titletexture.."]"..
		"textarea[0.3,1.5;7,8;;"..minetest.colorize("#111", minetest.formspec_escape(meta:get_string("text")))..";]"..
		"bgcolor[#0000]"

	if minetest.is_protected(pos, player:get_player_name()) then
		formspec = formspec..
			"button_exit[2.5,8;2,1;ok;"..F("Close").."]"
	else
		formspec = formspec..
			"button[1,8;2,1;edit;"..F("Edit").."]"..
			"button_exit[4,8;2,1;ok;"..F("Close").."]"
	end
	minetest.show_formspec(player:get_player_name(),
		node.name.."@"..minetest.pos_to_string(pos)..":display",
		formspec)
end

local function edit_poster(pos, node, player)
	local formspec
	local meta = minetest.get_meta(pos)

	if not minetest.is_protected(pos, player:get_player_name()) then
		formspec =
			"size[6.5,7.5]"..
			"field[0.5,0.7;6,1;display_text;"..F("Title")..";"..
            minetest.formspec_escape(meta:get_string("display_text")).."]"..
			"textarea[0.5,1.7;6,6;text;"..F("Text")..";"..
            minetest.formspec_escape(meta:get_string("text")).."]"..
			"button_exit[2.25,7;2,1;write;"..F("Write").."]"
		minetest.show_formspec(player:get_player_name(),
			node.name.."@"..minetest.pos_to_string(pos)..":edit",
			formspec)
	end
end

-- Poster specific on_receive_fields callback
local function on_receive_fields_poster(pos, formname, fields, player)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)

	if not minetest.is_protected(pos, player:get_player_name()) and fields then
		if formname == node.name.."@"..minetest.pos_to_string(pos)..":display" and 
		  fields.edit then
			edit_poster(pos, node, player)
		end
		if formname == node.name.."@"..minetest.pos_to_string(pos)..":edit" and
		   (fields.write or fields.key_enter) then
			meta:set_string("display_text", fields.display_text)
			meta:set_string("text", fields.text)
			meta:set_string("infotext", "\""..fields.display_text
					.."\"\n"..S("(right-click to read more text)"))
			display_lib.update_entities(pos)
			display_poster(pos, node, player)
		end
	end
end

-- Text entity for all signs
display_lib.register_display_entity("signs:display_text")

-- Sign models and registration
local models = {
	wooden_right_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
            right = -3/32,
			size = { x = 12/16, y = 6/16 },
			resolution = { x = 112, y = 64 },
			maxlines = 2,
			color="#000",
		},
		node_fields = {
			description = S("Wooden direction sign"),
			tiles = { "signs_wooden_direction.png" },
			inventory_image = "signs_wooden_inventory.png",
            signs_other_dir = 'signs:wooden_left_sign',
			on_place = signs.on_place_direction,
			drawtype = "mesh",
			mesh = "signs_dir_right.obj",
			selection_box = { type="fixed", fixed = {-0.5, -7/32, 0.5, 7/16, 7/32, 7/16}},
			collision_box = { type="fixed", fixed = {-0,5, -7/32, 0.5, 7/16, 7/32, 7/16}},
		},
	},
	wooden_left_sign = {
		depth = 1/16,
		width = 14/16,
		height = 7/16,
		entity_fields = {
            right = 3/32,
			size = { x = 12/16, y = 6/16 },
			resolution = { x = 112, y = 64 },
			maxlines = 2,
			color = "#000",
		},
		node_fields = {
			description = S("Wooden direction sign"),
			tiles = { "signs_wooden_direction.png" },
			inventory_image = "signs_wooden_inventory.png",
            signs_other_dir = 'signs:wooden_right_sign',
			drawtype = "mesh",
			mesh = "signs_dir_left.obj",
			selection_box = { type="fixed", fixed = {-7/16, -7/32, 0.5, 0.5, 7/32, 7/16}},
			collision_box = { type="fixed", fixed = {-7/16, -7/32, 0.5, 0.5, 7/32, 7/16}},
			groups = { not_in_creative_inventory = 1 },
			drop = "signs:wooden_right_sign",
		},
	},
	paper_poster = {
		depth = 1/32,
		width = 26/32,
		height = 30/32,
		entity_fields = {
			resolution = { x = 144, y = 64 },
			maxlines = 1,
			color="#000",
			valign="top",
		},
		node_fields = {
			description = S("Poster"),
			tiles = { "signs_poster_sides.png", "signs_poster_sides.png",
                      "signs_poster_sides.png", "signs_poster_sides.png", 
                      "signs_poster_sides.png", "signs_poster.png" },
			inventory_image = "signs_poster_inventory.png",
			on_construct = display_lib.on_construct,
			on_rightclick = display_poster,
			on_receive_fields = on_receive_fields_poster,
		},
	},
}

-- Node registration
for name, model in pairs(models)
do
	signs.register_sign("signs", name, model)
end

