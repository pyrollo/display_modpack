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

-- Prefered gap between node and entity
-- Entity positionment is up to mods but it is a good practice to use this
-- variable as spacing between entity and node
display_api.entity_spacing = 0.002

-- Settings
display_api.rotation_restriction =
	minetest.settings:get_bool("display_rotation_restriction", true)

if display_api.rotation_restriction then
	minetest.log("action", "[display_api] Legacy rotation restriction in effect")
end

-- Maximum entity position relative to the node pos
local max_entity_pos = 1.5

local wallmounted_rotations, facedir_rotations

if display_api.rotation_restriction then
	-- Legacy rotations (MT<5.0)
	wallmounted_rotations = {
		[2]={x=0, y=3, z=0}, [3]={x=0, y=1, z=0},
		[4]={x=0, y=0, z=0}, [5]={x=0, y=2, z=0},
	}
	facedir_rotations = {
		[0]={x=0, y=0, z=0}, [1]={x=0, y=3, z=0},
		[2]={x=0, y=2, z=0}, [3]={x=0, y=1, z=0},
	}
else
	-- Full rotations (MT>=5.0)
	wallmounted_rotations = {
		[0]={x=1, y=0, z=0}, [1]={x=3, y=0, z=0},
		[2]={x=0, y=3, z=0}, [3]={x=0, y=1, z=0},
		[4]={x=0, y=0, z=0}, [5]={x=0, y=2, z=0},
	}
	facedir_rotations = {
		[ 0]={x=0, y=0, z=0}, [ 1]={x=0, y=3, z=0},
		[ 2]={x=0, y=2, z=0}, [ 3]={x=0, y=1, z=0},
		[ 4]={x=3, y=0, z=0}, [ 5]={x=0, y=3, z=3},
		[ 6]={x=1, y=0, z=2}, [ 7]={x=0, y=1, z=1},
		[ 8]={x=1, y=0, z=0}, [ 9]={x=0, y=3, z=1},
		[10]={x=3, y=0, z=2}, [11]={x=0, y=1, z=3},
		[12]={x=0, y=0, z=1}, [13]={x=3, y=0, z=1},
		[14]={x=2, y=0, z=1}, [15]={x=1, y=0, z=1},
		[16]={x=0, y=0, z=3}, [17]={x=1, y=0, z=3},
		[18]={x=2, y=0, z=3}, [19]={x=3, y=0, z=3},
		[20]={x=0, y=0, z=2}, [21]={x=0, y=1, z=2},
		[22]={x=0, y=2, z=2}, [23]={x=0, y=3, z=2},
	}
end

-- Compute other useful values depending on wallmounted and facedir param
local wallmounted_values = {}
local facedir_values = {}

local function compute_values(r)
	local function rx(v) return { x=v.x, y=v.z, z=-v.y} end
	local function ry(v) return { x=-v.z, y=v.y, z=v.x} end
	local function rz(v) return { x=v.y, y=-v.x, z=v.z} end

	local d = { x = 0, y = 0, z = 1 }
	local w = { x = 1, y = 0, z = 0 }
	local h = { x = 0, y = 1, z = 0 }

	-- Important to keep z rotation first (not same results)
	for _ = 1, r.z do d, w, h = rz(d), rz(w), rz(h) end
	for _ = 1, r.x do d, w, h = rx(d), rx(w), rx(h) end
	for _ = 1, r.y do d, w, h = ry(d), ry(w), ry(h) end

	return {rotation=r, depth=d, width=w, height=h}
end

for i, r in pairs(facedir_rotations) do
	facedir_values[i] = compute_values(r)
end

for i, r in pairs(wallmounted_rotations) do
	wallmounted_values[i] = compute_values(r)
end

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

--- Gets the display entities attached with a node. Removes extra ones
local function get_entities(pos)
	local objrefs = {}
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.display_entities then
		for _, objref in
			ipairs(minetest.get_objects_inside_radius(pos, max_entity_pos)) do
			local entity = objref:get_luaentity()
			if entity and ndef.display_entities[entity.name] and
				 entity.nodepos and vector.equals(pos, entity.nodepos) then
				if objrefs[entity.name] then
					objref:remove() -- Remove duplicates
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
		return math.max(-max_entity_pos, math.min(max_entity_pos, posprop))
	else
		return 0
	end
end

--- (Create and) place display entities according to the node orientation
local function place_entities(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local v = get_values(node)
	local objrefs = get_entities(pos)

	if v and ndef and ndef.display_entities then
		for entity_name, props in pairs(ndef.display_entities) do
			local depth = clip_pos_prop(props.depth)
			local right = clip_pos_prop(props.right)
			local top = clip_pos_prop(props.top)
			if not objrefs[entity_name] then
				objrefs[entity_name] = minetest.add_entity(pos, entity_name,
					minetest.serialize({ nodepos = pos }))
			end

			objrefs[entity_name]:set_pos({
				x = pos.x + v.depth.x*depth + v.width.x*right - v.height.x*top,
				y = pos.y + v.depth.y*depth + v.width.y*right - v.height.y*top,
				z = pos.z + v.depth.z*depth + v.width.z*right - v.height.z*top,
			})

			if objrefs[entity_name].set_rotation then
				objrefs[entity_name]:set_rotation({
					x = v.rotation.x*math.pi/2,
					y = v.rotation.y*math.pi/2 + (props.yaw or 0),
					z = v.rotation.z*math.pi/2,
				})
			else -- For minetest < 5.0 -- TODO: To be removed in the future
				objrefs[entity_name]:set_yaw(v.rotation.y*math.pi/2 + (props.yaw or 0))
			end
		end
	end
	return objrefs
end

--- Entity update
function update_entity(entity)
	if not entity then
		return
	end

	if not entity.nodepos then
		entity.object:remove() -- Remove old/buggy entity
		return
	end

	local node = minetest.get_node(entity.nodepos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.display_entities and
		 ndef.display_entities[entity.name] and
		 ndef.display_entities[entity.name].on_display_update
	then
		-- Call on_display_update callback of a node for one of its display entities
		ndef.display_entities[entity.name].on_display_update(entity.nodepos,
			entity.object)
  else
		-- Display node has been removed, remove entity also
		entity.object:remove()
	end
end

--- Force entity update
function display_api.update_entities(pos)
	for _, objref in pairs(place_entities(pos)) do
		update_entity(objref:get_luaentity())
	end
end

--- On_activate callback for display_api entities. Calls on_display_update callbacks
--- of corresponding node for each entity.
function display_api.on_activate(entity, staticdata)
	if entity then
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				entity.nodepos = data.nodepos
			end
			entity.object:set_armor_groups({immortal=1})
		end
		update_entity(entity)
	end
end

--- On_place callback for display_api items.
-- Does nothing more than preventing node from being placed on ceiling or ground
-- TODO:When MT<5 is not in use anymore, simplify this
function display_api.on_place(itemstack, placer, pointed_thing, override_param2)
	local ndef = itemstack:get_definition()
	local dir = {
		x = pointed_thing.under.x - pointed_thing.above.x,
		y = pointed_thing.under.y - pointed_thing.above.y,
		z = pointed_thing.under.z - pointed_thing.above.z,
	}

	if display_api.rotation_restriction then
		-- If item is not placed on a wall, use the player's view direction instead
		if dir.x == 0 and dir.z == 0 then
			dir = placer:get_look_dir()
		end
		dir.y = 0
	end

	local param2 = 0
	if ndef then
		if ndef.paramtype2 == "wallmounted" or
			ndef.paramtype2 == "colorwallmounted" then
			param2 = minetest.dir_to_wallmounted(dir)

		elseif ndef.paramtype2 == "facedir" or
			ndef.paramtype2 == "colorfacedir"  then
			param2 = minetest.dir_to_facedir(dir, not display_api.rotation_restriction)
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing,
		param2 + (override_param2 or 0))
end

--- On_construct callback for display_api items.
-- Creates entities and update them.
function display_api.on_construct(pos)
	display_api.update_entities(pos)
end

--- On_destruct callback for display_api items.
-- Removes entities.
function display_api.on_destruct(pos)
	for _, objref in pairs(get_entities(pos)) do
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
	if not minetest.registered_entities[entity_name] then
		minetest.register_entity(':'..entity_name, {
			collisionbox = { 0, 0, 0, 0, 0, 0 },
			visual = "upright_sprite",
			textures = {},
			on_activate = display_api.on_activate,
			get_staticdata = function(self)
				return minetest.serialize({ nodepos = self.nodepos })
			end,
		})
	end
end

minetest.register_lbm({
	label = "Update display_api entities",
	name = "display_api:update_entities",
	run_at_every_load = true,
	nodenames = {"group:display_api",
		"group:display_modpack_node", "group:display_lib_node"}, -- See deprecated(1)
	action = function(pos, node) display_api.update_entities(pos) end,
})
