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

function steles.on_receive_fields(pos, formname, fields, player)
	if not minetest.is_protected(pos, player:get_player_name()) then
		local meta = minetest.get_meta(pos)
		if fields and fields.ok then
			meta:set_string("display_text", fields.display_text)
			meta:set_string("infotext", "\""..fields.display_text.."\"")
			display_lib.update_entities(pos)
		end
	end
end

display_lib.register_display_entity("steles:text")

for i, material in ipairs(steles.materials) do

	local ndef = minetest.registered_nodes[material]

	if ndef then
		local parts = material:split(":")

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
					{-5/16, -4/16, -2/16, 5/16, 0.5, 2/16},
					{-7/16, -0.5, -4/16, 7/16, -4/16, 4/16}
				}
			},
			groups = ndef.groups,
			display_entities = {
				["steles:text"] = {
						on_display_update = font_lib.on_display_update,
						depth = -2/16-0.001, height = 2/16,
						size = { x = 14/16, y = 12/16 },
						resolution = { x = 144, y = 64 },
						maxlines = 3,
				},
			},
			on_place = display_lib.on_place,
			on_construct = 	function(pos)
								local meta = minetest.get_meta(pos)
								meta:set_string("formspec", "size[6,4]"
									.."textarea[0.5,0.7;5.5,2;display_text;"
									..F("Displayed text (3 lines max)")
									..";${display_text}]"
									.."button_exit[2,3;2,1;ok;"..F("Write").."]")
								display_lib.on_construct(pos)
							end,
			on_destruct = display_lib.on_destruct,
			on_rotate = display_lib.on_rotate,
			on_receive_fields = function(pos, formname, fields, player)
									if not minetest.is_protected(pos, player:get_player_name()) then
										local meta = minetest.get_meta(pos)
										if fields and fields.ok then
											meta:set_string("display_text", fields.display_text)
											meta:set_string("infotext", "\""..fields.display_text.."\"")
											display_lib.update_entities(pos)
										end
									end
								end,
			on_punch = function(pos, node, player, pointed_thing) display_lib.update_entities(pos) end,
		})
	end
end
