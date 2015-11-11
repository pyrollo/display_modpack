-- Display lib mod by P.Y. Rollo
--
-- License: WTFPL

display_lib = {}

-- Miscelaneous values depending on wallmounted param2
local wallmounted_values = {
	[0]={dx=0,  dz=0,  lx=0, lz=0,  yaw=0,          rotate=0}, -- Should never be used
		{dx=1,  dz=0,  lx=0, lz=0,  yaw=0,          rotate=1}, -- Should never be used 
		{dx=1,  dz=0,  lx=0, lz=-1, yaw=-math.pi/2, rotate=4},
		{dx=-1, dz=0,  lx=0, lz=1,  yaw=math.pi/2,  rotate=5},
		{dx=0,  dz=1,  lx=1, lz=0,  yaw=0,          rotate=3},
		{dx=0,  dz=-1, lx=-1, lz=0, yaw=math.pi,    rotate=2}
}

--- Gets the display entities attached with a node. Removes extra ones
local function get_entities(pos)
	local objrefs = {}
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.display_entities then
		for _, objref in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
			local entity = objref:get_luaentity()
		    if entity and ndef.display_entities[entity.name] then
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
		return math.max(-0.5, math.min(0.5, posprop))
	else
		return 0
	end
end

--- (Create and) place display entities according to the node orientation
local function place_entities(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local values = wallmounted_values[node.param2]
	local objrefs = get_entities(pos)

	if ndef and ndef.display_entities then
		for entity_name, props in pairs(ndef.display_entities) do
			local depth = clip_pos_prop(props.depth)
			local top = clip_pos_prop(props.top)
			local left = clip_pos_prop(props.left)
			
			if not objrefs[entity_name] then
				objrefs[entity_name] = minetest.add_entity(pos, entity_name)
			end

			objrefs[entity_name]:setpos({
				x = pos.x - values.dx * depth + values.lx * left,
				y = pos.y + top,
				z = pos.z - values.dz * depth + values.lz * left})

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
function display_lib.update_entities(pos)
	local objrefs = place_entities(pos)
	for _, objref in pairs(objrefs) do
		call_node_on_display_update(pos, objref)
    end
end

--- On_activate callback for display_lib entities. Calls on_display_update callbacks 
--- of corresponding node for each entity.
function display_lib.on_activate(entity, staticdata)
	if entity then
		call_node_on_display_update(entity.object:getpos(), entity.object)
	end
end

--- On_place callback for display_lib items. Does nothing more than preventing item
--- from being placed on ceiling or ground 
function display_lib.on_place(itemstack, placer, pointed_thing)
	local above = pointed_thing.above
	local under = pointed_thing.under
	local dir = {x = under.x - above.x,
				 y = under.y - above.y,
				 z = under.z - above.z}
	local wdir = minetest.dir_to_wallmounted(dir)

	if wdir == 0 or wdir == 1 then
		dir = placer:get_look_dir()
		dir.y = 0
		wdir = minetest.dir_to_wallmounted(dir)
	end
	return minetest.item_place(itemstack, placer, pointed_thing, wdir) 
end

--- On_construct callback for display_lib items. Creates entities and update them.
function display_lib.on_construct(pos)
	display_lib.update_entities(pos)
end

--- On_destruct callback for display_lib items. Removes entities.
function display_lib.on_destruct(pos)
	local objrefs = get_entities(pos)
	
	for _, objref in pairs(objrefs) do 
		objref:remove()
	end
end


-- On_rotate (screwdriver) callback for display_lib items. Prevents axis rotation and reorients entities.
function display_lib.on_rotate(pos, node, user, mode, new_param2)
	if mode ~= screwdriver.ROTATE_FACE then return false end

	if wallmounted_values[node.param2] then
		minetest.swap_node(pos, {name = node.name, param1 = node.param1, param2 = wallmounted_values[node.param2].rotate})
		place_entities(pos)
		return true
	else
		return false
	end
end

--- Creates display entity with some fields and the on_activate callback
function display_lib.register_display_entity(entity_name)
	if not minetest.registered_entity then
		minetest.register_entity(':'..entity_name, {
			collisionbox = { 0, 0, 0, 0, 0, 0 },
			visual = "upright_sprite",
			textures = {},
			on_activate = display_lib.on_activate,
		})
	end
end



