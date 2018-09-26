--[[
    display_api mod for Minetest - Library to add dynamic display
    capabilities to nodes
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

display_api = {}

-- Prefered gap between node and entity
-- Entity positionment is up to mods but it is a good practice to use this
-- variable as spacing between entity and node
display_api.entity_spacing = 0.002

-- Miscelaneous values depending on wallmounted param2
local wallmounted_values = {
	[2]={dx=-1, dz=0,  rx=0,  rz=-1, yaw=-math.pi/2},
	[3]={dx=1,  dz=0,  rx=0,  rz=1,  yaw=math.pi/2 },
	[4]={dx=0,  dz=-1, rx=1,  rz=0,  yaw=0         },
	[5]={dx=0,  dz=1,  rx=-1, rz=0,  yaw=math.pi   }
}

-- Miscelaneous values depending on facedir param2
local facedir_values = {
	[0]={dx=0,  dz=-1, rx=1,  rz=0,  yaw=0         },
	[1]={dx=-1, dz=0,  rx=0,  rz=-1, yaw=-math.pi/2},
	[2]={dx=0,  dz=1,  rx=-1, rz=0,  yaw=math.pi   },
	[3]={dx=1,  dz=0,  rx=0,  rz=1,  yaw=math.pi/2 }
}

-- dx/dy = depth vector, rx/ly = right vector, yaw = yaw of entity,
local function get_values(node)
	local ndef = minetest.registered_nodes[node.name]
	
	if ndef then
		local paramtype2 = ndef.paramtype2
		if paramtype2 == "wallmounted" or paramtype2 == "colorwallmounted" then
			return wallmounted_values[node.param2 % 8]
		elseif paramtype2 == "facedir" or paramtype2 == "colorfacedir"  then
			return facedir_values[node.param2 % 32]
		end
	end
end

--- Checks if the object is related to the given position
local function check_entity_pos(pos, objref)
	local real_pos = vector.round(objref:get_pos())
	local pos_hash = objref:get_luaentity().pos
	if pos_hash == nil then
		return vector.equals(real_pos, vector.round(pos))
	else
		return vector.equals(minetest.get_position_from_hash(pos_hash), pos)
	end
end

--- Gets the display entities attached with a node. Removes extra ones
local function get_entities(pos)
	local objrefs = {}
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.display_entities then
		for _, objref in ipairs(minetest.get_objects_inside_radius(pos, 1.5)) do
			local entity = objref:get_luaentity()
			if entity and ndef.display_entities[entity.name] and check_entity_pos(pos, objref) then
				if objrefs[entity.name] then
					objref:remove()
				else
					objrefs[entity.name] = objref
				end
			end
		end
	end
	return objrefs
end

local function clip_pos_prop(posprop)
	if posprop then
		return math.max(-1.5, math.min(1.5, posprop))
	else
		return 0
	end
end

--- (Create and) place display entities according to the node orientation
local function place_entities(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local values = get_values(node)
	local objrefs = get_entities(pos)
	
	if values and ndef and ndef.display_entities then
		
		for entity_name, props in pairs(ndef.display_entities) do
			local depth = clip_pos_prop(props.depth)
			local right = clip_pos_prop(props.right)
			local top = clip_pos_prop(props.top)
			if not objrefs[entity_name] then
				objrefs[entity_name] = minetest.add_entity(pos, entity_name)
			end
			
			objrefs[entity_name]:setpos({
				x = pos.x - values.dx * depth + values.rx * right,
				y = pos.y - top,
				z = pos.z - values.dz * depth + values.rz * right})
			
			objrefs[entity_name]:setyaw(values.yaw)
		end
	end
	return objrefs
end

--- Call on_display_update callback of a node for one of its display entities
local function call_node_on_display_update(pos, objref)
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	local entity = objref:get_luaentity()
	if ndef and ndef.display_entities and entity and ndef.display_entities[entity.name] then
		ndef.display_entities[entity.name].on_display_update(pos, objref)
	end
end

--- Force entity update
function display_api.update_entities(pos)
	local objrefs = place_entities(pos)
	for _, objref in pairs(objrefs) do
		objref:get_luaentity().pos = minetest.hash_node_position(pos)
		call_node_on_display_update(pos, objref)
	end
end

--- On_activate callback for display_api entities. Calls on_display_update callbacks
--- of corresponding node for each entity.
function display_api.on_activate(entity, staticdata)
	if entity then
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = core.deserialize(staticdata)
			if data and type(data) == "table" then
				entity.pos = data.pos
			end
		end
		entity.object:set_armor_groups({immortal=1})
		local pos
		if entity.pos then
			pos = minetest.get_position_from_hash(entity.pos)
		else
			pos = entity.object:getpos()
		end
		display_api.update_entities(pos)
	end
end

--- On_place callback for display_api items. Does nothing more than preventing item
--- from being placed on ceiling or ground 
function display_api.on_place(itemstack, placer, pointed_thing, override_param2)
	local ndef = itemstack:get_definition()
	local above = pointed_thing.above
	local under = pointed_thing.under
	local dir = {x = under.x - above.x,
	             y = 0,
	             z = under.z - above.z}
	
	-- If item is not placed on a wall, use the player's view direction instead
	if dir.x == 0 and dir.z == 0 then
		dir = placer:get_look_dir()
		dir.y = 0
	end
	
	local param2 = 0
	if ndef then
		local paramtype2 = ndef.paramtype2
		if paramtype2 == "wallmounted" or paramtype2 == "colorwallmounted" then
			param2 = minetest.dir_to_wallmounted(dir)
		elseif paramtype2 == "facedir" or paramtype2 == "colorfacedir"  then
			param2 = minetest.dir_to_facedir(dir)
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2 + (override_param2 or 0))
end

--- On_construct callback for display_api items. Creates entities and update them.
function display_api.on_construct(pos)
	display_api.update_entities(pos)
end

--- On_destruct callback for display_api items. Removes entities.
function display_api.on_destruct(pos)
	local objrefs = get_entities(pos)
	
	for _, objref in pairs(objrefs) do 
		objref:remove()
	end
end

-- On_rotate (screwdriver) callback for display_api items. Prevents invalid rotations and reorients entities.
function display_api.on_rotate(pos, node, user, _, new_param2)
	node.param2 = new_param2
	if get_values(node) then
		minetest.swap_node(pos, node)
		place_entities(pos)
		return true
	else
		return false
	end
end

--- Creates display entity with some fields and the on_activate callback
function display_api.register_display_entity(entity_name)
	if not minetest.registered_entity then
		minetest.register_entity(':'..entity_name, {
			collisionbox = { 0, 0, 0, 0, 0, 0 },
			visual = "upright_sprite",
			textures = {},
			on_activate = display_api.on_activate,
			get_staticdata = function(self)
				return minetest.serialize({
					pos = self.pos,
				})
			end,
		})
	end
end

minetest.register_lbm({
	label = "Update display_api entities",
	name = "display_api:update_entities",
	run_at_every_load = true,
	nodenames = {"group:display_modpack_node", "group:display_lib_node"},
	action = function(pos, node) display_api.update_entities(pos) end,
})

-- Compatibility
display_lib = display_api
