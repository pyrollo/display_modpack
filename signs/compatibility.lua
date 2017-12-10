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


-- Wallmounted to facedir conversion
------------------------------------

local wallmounted_to_facedir = {
  [0]=1, -- Should not happend with signs 
  [1]=1, -- Should not happend with signs
  [2]=1,
  [3]=3,
  [4]=0,
  [5]=2
}

-- Nodes conversions
local convert_nodes = {
  ['signs:wooden_right'] = 'signs:wooden_right_sign',
  ['signs:wooden_left']  = 'signs:wooden_left_sign',
  ['signs:poster']       = 'signs:paper_poster'
}

local function compatibility_check_1(pos, node)
    -- Old wallmounted modes to new facedir nodes conversion
    node.name = convert_nodes[node.name]
    if node.name then
	  node.param2 = wallmounted_to_facedir[node.param2]
      display_lib.on_destruct(pos)
      minetest.swap_node(pos, node)
      display_lib.on_construct(pos)
    end
end

minetest.register_lbm({ name = "signs:conpatibility_1",
	nodenames = {"signs:wooden_right", "signs:wooden_left", "signs:poster"},
	action = compatibility_check_1,
})

-- Text entity name change because of signs_lib using signs prefix
------------------------------------------------------------------

-- If no other mod registered signs:text, register it.
-- We need to have this entity registered to be able to remove it.
if minetest.registered_entities["signs:text"] == nil then
	minetest.register_entity("signs:text", {
		collisionbox = { 0, 0, 0, 0, 0, 0 },
		visual = "upright_sprite",
		textures = {},
	})
end

local function compatibility_check_2(pos, node)
	-- Remove old entity
	for _, objref in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		local entity = objref:get_luaentity()
	    if entity and entity.name == "signs:text" then
		    objref:remove()
		end
	end
	-- Create new entity
	display_lib.update_entities(pos)
end

minetest.register_lbm({ name = "signs:conpatibility_2",
	nodenames = {"signs:wooden_right_sign", "signs:wooden_left_sign", "signs:paper_poster"},
	action = compatibility_check_2,
})





