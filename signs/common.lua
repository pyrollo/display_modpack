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

function signs.set_display_text(pos,text)
	local meta = minetest.get_meta(pos)
	meta:set_string("display_text", text)
	meta:set_string("infotext", "\""..text.."\"")
	display_lib.update_entities(pos)
end

function signs.set_formspec(pos)
	local meta = minetest.get_meta(pos)
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.display_entities and ndef.display_entities["signs:display_text"] then
		local maxlines = ndef.display_entities["signs:display_text"].maxlines
		local formspec

		if maxlines == 1 then
			formspec = "size[6,3]"..
				default.gui_bg .. default.gui_bg_img .. default.gui_slots ..
				"field[0.5,0.7;5.5,1;display_text;"..F("Text")..";${display_text}]"..
				"button_exit[2,2;2,1;ok;"..F("Write").."]"
		else
			local extralabel = ""
			if maxlines then
				extralabel = F(" (first %s lines only)"):format(maxlines)
			end

			formspec = "size[6,4]"..
				default.gui_bg .. default.gui_bg_img .. default.gui_slots ..
				"textarea[0.5,0.7;5.5,2;display_text;"..F("Text")..""..extralabel..";${display_text}]"..
				"button_exit[2,3;2,1;ok;"..F("Write").."]"
		end

		meta:set_string("formspec", formspec)
	end
end

function signs.on_receive_fields(pos, formname, fields, player)
	if not minetest.is_protected(pos, player:get_player_name()) then
		if fields and (fields.ok or fields.key_enter) then
			signs.set_display_text(pos, fields.display_text)
		end
	end
end

-- On place callback for direction signs 
-- (chooses which sign according to look direction)
function signs.on_place_direction(itemstack, placer, pointed_thing)
	local name = itemstack:get_name()
	local ndef = minetest.registered_nodes[name]

    local bdir = {x = pointed_thing.under.x - pointed_thing.above.x,
                  y = pointed_thing.under.y - pointed_thing.above.y,
                  z = pointed_thing.under.z - pointed_thing.above.z}
	local pdir = placer:get_look_dir()

	local ndir, test

	if ndef.paramtype2 == "facedir" then
		if bdir.x == 0 and bdir.z == 0 then
			-- Ceiling or floor pointed (facedir chosen from player dir)
			ndir = minetest.dir_to_facedir({x=pdir.x, y=0, z=pdir.z})
		else
			-- Wall pointed
			ndir = minetest.dir_to_facedir(bdir)
		end

		test = {[0]=-pdir.x, pdir.z, pdir.x, -pdir.z}
    end

	if ndef.paramtype2 == "wallmounted" then
		ndir = minetest.dir_to_wallmounted(bdir)
		if ndir == 0 or ndir == 1 then
			-- Ceiling or floor
			ndir = minetest.dir_to_wallmounted({x=pdir.x, y=0, z=pdir.z})
		end

		test = {0, pdir.z, -pdir.z, -pdir.x, pdir.x}
	end

	-- Only for direction signs
	if ndef.signs_other_dir then
		if test[ndir] > 0 then
			itemstack:set_name(ndef.signs_other_dir)
		end
		itemstack = minetest.item_place(itemstack, placer, pointed_thing, ndir)
		itemstack:set_name(name)

		return itemstack
	else
		return minetest.item_place(itemstack, placer, pointed_thing, ndir)
	end
end

-- Handles screwdriver rotation. Direction is affected for direction signs
function signs.on_rotate(pos, node, player, mode, new_param2)
	if mode == 2 then
    	local ndef = minetest.registered_nodes[node.name]
	    if ndef.signs_other_dir then
		    minetest.swap_node(pos, {name = ndef.signs_other_dir, 
                param1 = node.param1, param2 = node.param2})
			display_lib.update_entities(pos)
	    end
	else
        display_lib.on_rotate(pos, node, user, mode, new_param2)
	end
    return false;
end

-- Generic callback for show_formspec displayed formspecs of "sign" mod

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local found, _, mod, node_name, pos = formname:find("^([%w_]+):([%w_]+)@([^:]+)")
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
		paramtype2 = "facedir",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {-model.width/2, -model.height/2, 0.5,
					 model.width/2, model.height/2, 0.5 - model.depth},
		},
		groups = {choppy=2, dig_immediate=2, not_blocking_trains = 1, display_lib_node = 1},
		sounds = default.node_sound_defaults(),
		display_entities = {
			["signs:display_text"] = {
					on_display_update = font_lib.on_display_update,
					depth = 0.5 - display_lib.entity_spacing - model.depth,
					size = { x = model.width, y = model.height },
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
		on_rotate = signs.on_rotate,
 		on_receive_fields =  signs.on_receive_fields,
		on_punch = function(pos, node, player, pointed_thing) display_lib.update_entities(pos) end,
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
		fields.display_entities["signs:display_text"][key] = value
	end

	minetest.register_node(mod..":"..name, fields)
end
