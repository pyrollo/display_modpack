--[[
    steles mod for Minetest. Steles / graves with text on it.
    (c) Pierre-Yves Rollo

    This file is part of steles.

    steles is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    steles is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with steles.  If not, see <http://www.gnu.org/licenses/>.
--]]

local S = steles.intllib
local F = function(...) return minetest.formspec_escape(S(...)) end

display_api.register_display_entity("steles:text")

for i, material in ipairs(steles.materials) do

	local ndef = minetest.registered_nodes[material]

	if ndef then
		local groups = table.copy(ndef.groups)
		local parts = material:split(":")
		groups.display_api = 1

		minetest.register_node("steles:"..parts[2].."_stele", {
			description = steles.materials_desc[i],
			sunlight_propagates = true,
			paramtype = "light",
			paramtype2 = "facedir",
			tiles = ndef.tiles,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-5/16, -5/16, -2/16, 5/16, 0.5, 2/16},
					{-7/16, -0.5, -4/16, 7/16, -5/16, 4/16}
				},
			},
			groups = groups,
			display_entities = {
				["steles:text"] = {
						on_display_update = font_api.on_display_update,
						depth = -2/16 - display_api.entity_spacing,
						top = -2/16,
						aspect_ratio = 0.4,
						size = { x = 10/16, y = 12/16 },
						maxlines = 3,
				},
			},
			on_place = function(itemstack, placer, pointed_thing)
					minetest.rotate_node(itemstack, placer, pointed_thing)
					return display_api.on_place(itemstack, placer, pointed_thing)
				end,
			on_construct = 	function(pos)
					local meta = minetest.get_meta(pos)
					meta:set_string("formspec", string.format([=[
						size[6,4]%s%s%s
						textarea[0.5,0.7;5.5,2;display_text;%s;${display_text}]
						button[1,3;2,1;font;%s]
						button_exit[3,3;2,1;ok;%s]]=],
						default.gui_bg, default.gui_bg_img, default.gui_slots,
						F("Displayed text (3 lines max)"),
						F("Font"), F("Write")))
					display_api.on_construct(pos)
				end,
			on_destruct = display_api.on_destruct,
			on_rotate = display_api.on_rotate,
			on_receive_fields = function(pos, formname, fields, player)
					if not minetest.is_protected(pos, player:get_player_name()) then
						local meta = minetest.get_meta(pos)
						if fields.ok or fields.font then
							meta:set_string("display_text", fields.display_text)
							meta:set_string("infotext", "\""..fields.display_text.."\"")
							display_api.update_entities(pos)
						end
						if fields.font then
							font_api.show_font_list(player, pos)
						end
					end
				end,
			on_punch = display_api.update_entities,
		})
	end
end
