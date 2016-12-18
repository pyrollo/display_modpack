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

function signs.set_formspec(pos)
	local meta = minetest.get_meta(pos)
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.display_entities and ndef.display_entities["signs:text"] then
		local maxlines = ndef.display_entities["signs:text"].maxlines
		local formspec

		if maxlines == 1 then
			formspec = "size[6,3]"..
				"field[0.5,0.7;5.5,1;display_text;Displayed text;${display_text}]"..
				"button_exit[2,2;2,1;ok;Write]"
		else
			local extralabel = ""
			if maxlines then
				extralabel = " (first "..maxlines.." lines only)"
			end

			formspec = "size[6,4]"..
				"textarea[0.5,0.7;5.5,2;display_text;Displayed text"..extralabel..";${display_text}]"..
				"button_exit[2,3;2,1;ok;Write]"
		end

		meta:set_string("formspec", formspec)
	end
end

function signs.on_receive_fields(pos, formname, fields, player)
	if not minetest.is_protected(pos, player:get_player_name()) then
		local meta = minetest.get_meta(pos)
		if fields and fields.ok then
			meta:set_string("display_text", fields.display_text)
			meta:set_string("infotext", "\""..fields.display_text.."\"")
			display_lib.update_entities(pos)
		end
	end
end

-- On place callback for direction signs 
-- (chooses which sign according to look direction)
function signs.on_place_direction(itemstack, placer, pointed_thing)
	local above = pointed_thing.above
	local under = pointed_thing.under
	local wdir = minetest.dir_to_wallmounted(
				{x = under.x - above.x,
				 y = under.y - above.y,
				 z = under.z - above.z})
	
	local dir = placer:get_look_dir()

	if wdir == 0 or wdir == 1 then
		wdir = minetest.dir_to_wallmounted({x=dir.x, y=0, z=dir.z})
	end

	local name = itemstack:get_name()

	-- Only for direction signs (ending with _right)
	if name:sub(-string.len("_right")) == "_right" then
		name = name:sub(1, -string.len("_right"))

		local test = {0, dir.z, -dir.z, -dir.x, dir.x}
		if test[wdir] > 0 then
			itemstack:set_name(name.."left")
		end
		itemstack = minetest.item_place(itemstack, placer, pointed_thing, wdir)
		itemstack:set_name(name.."right")

		return itemstack
	else
		return minetest.item_place(itemstack, placer, pointed_thing, wdir)
	end
end

-- Screwdriver is no more usable for switching direction as on_rotate
-- callback is not called anymore for wallmounted nodes since 
-- minetest_game commit of 24 dec 2015. Now we use right click.
function signs.on_right_click_direction(pos, node, player, itemstack, pointed_thing)
	if not minetest.is_protected(pos, player:get_player_name()) then
	    local name
	    if node.name:sub(-string.len("_right")) == "_right" then
		    name = node.name:sub(1, -string.len("_right")).."left"
	    end
	    if node.name:sub(-string.len("_left")) == "_left" then
		    name = node.name:sub(1, -string.len("_left")).."right"
	    end

	    if name then
		    minetest.swap_node(pos, {name = name, param1 = node.param1, param2 = node.param2})
	    end
    end

    return itemstack
end

-- Generic callback for show_formspec displayed formspecs
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local found, _, mod, node_name, pos = formname:find("([%w_]+):([%w_]+)@(.+)")

	if found then
		if mod ~= 'signs' then return end

		local ndef = minetest.registered_nodes[mod..":"..node_name]

		if ndef and ndef.on_receive_fields then
			ndef.on_receive_fields(minetest.string_to_pos(pos), formname, fields, player)
		end
	end
end)

function signs.register_sign(mod, name, model)
	-- Default fields
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
		groups = {choppy=2, dig_immediate=2, attached_node=1},
		sounds = default.node_sound_defaults(),
		display_entities = {
			["signs:text"] = {
					on_display_update = font_lib.on_display_update,
					depth = 0.499 - model.depth,
					size = { x = 1, y = 1 },
					resolution = { x = 64, y = 64 },
					maxlines = 1,
			},

		},
		on_place = display_lib.on_place,
		on_construct = 	function(pos)
							signs.set_formspec(pos)
							display_lib.on_construct(pos)
						end,
		on_destruct = display_lib.on_destruct,
 		on_receive_fields = signs.on_receive_fields,
	}

	-- Node fields override
	for key, value in pairs(model.node_fields) do
		if key == "groups" then
			for key2, value2 in pairs(value) do
				fields[key][key2] = value2
			end
		else
			fields[key] = value
		end
	end

	if not fields.wield_image then fields.wield_image = fields.inventory_image end

	-- Entity fields override
	for key, value in pairs(model.entity_fields) do
		fields.display_entities["signs:text"][key] = value
	end

	minetest.register_node(mod..":"..name, fields)
end
