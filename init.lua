--[[
    font_api mod for Minetest - Library to add font display capability
    to display_api mod.
    (c) Pierre-Yves Rollo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Global variables
-------------------

font_api = {}
font_api.name = minetest.get_current_modname()
font_api.path = minetest.get_modpath(font_api.name)

-- Inclusions
-------------

dofile(font_api.path.."/font.lua")
dofile(font_api.path.."/registry.lua")

--- Standard on_display_update entity callback.
-- Node should have a corresponding display_entity with size, resolution and 
-- maxlines fields and optionally halign, valign and color fields
-- @param pos Node position
-- @param objref Object reference of entity

function font_api.on_display_update(pos, objref)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("display_text")
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	local entity = objref:get_luaentity()

	if entity and ndef.display_entities[entity.name] then
		local def = ndef.display_entities[entity.name]
		local font = font_api.get_font(meta:get_string("font") ~= ""
			and meta:get_string("font") or def.font_name)

		local maxlines = def.maxlines or 1 -- TODO:How to do w/o maxlines ?

		objref:set_properties({ 		 
			textures={font:make_text_texture(text, 
				font:get_height(maxlines) * def.size.x / def.size.y
					/ (def.aspect_ratio or 1),
				font:get_height(maxlines),
				def.maxlines, def.halign, def.valign, def.color)},
			visual_size = def.size
		})
	end
end

-- Compatibility
font_lib = font_api

