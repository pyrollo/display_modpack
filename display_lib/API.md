# Display Lib API
This document describes Display Lib API. Display Lib allows to add a dynamic display on a node. Node must be wallmounted and Display Lib limits its rotation to vertical positions. 
## Provided methods
### update\_entities
**display\_lib.update\_entities(pos)**

This method triggers entities update for the display node at pos. Actual entity update is made by **on\_display\_update** callback associated to the entity.

**pos**: Position of the node
### register\_display\_entity
**display\_lib.register\_display\_entity(entity_name)**

This is a helper to register entities used for display. 

**entity_name**: Name of the entity to register.
## Provided callback implementations
### on_place
**display\_lib.on\_place(itemstack, placer, pointed\_thing)**

**On_place** node callback implementation. Display nodes should have this callback (avoid placement of horizontal display node).
### on_construct
**display\_lib.on\_construct(pos)**

**On_construct** node callback implementation. Display nodes should have this callback (creates, places and updates display entities on node construction).
### on_destruct
**display\_lib.on_destruct(pos)**

**On_destruct** node callback implementation. Display nodes should have this callback (removes display entities on node destruction). 
### on_rotate
**display\_lib.on\_rotate(pos, node, user, mode, new_param2)**

**On_rotate** node callback implementation. Display nodes should have this callback (restricts rotations and rotates display entities associated with node).
### on_activate
**display\_lib.on_activate(entity, staticdata)**

**On_activate** entity callback implementation for display entities. No need of this method if display entities have been registered using **register\_display\_entity** (callback is already set). 
## Howto register a display node
* Register display entities with **register\_display\_entity**
* Register node with :
	- **on\_place**, **on\_construct**, **on\_destruct** and **on\_rotate** callbacks using **display\_lib** callbacks.
	- a **display\_entities** field in node definition containing a entity name indexed table. For each entity, two fields : **depth** indicates the entity position (-0.5 to 0.5) and **on_display_update** is a callback in charge of setting up entity texture.

### Example

		display_lib.register_display_entity("mymod:entity1")
		display_lib.register_display_entity("mymod:entity2")

		function my_display_update1(pos, objref) 
			objref:set_properties({ textures= {"mytexture1.png"},
									visual_size = {x=1, y=1} })
		end

		function my_display_update2(pos, objref) 
			objref:set_properties({ textures= {"mytexture2.png"},
									visual_size = {x=1, y=1} })
		end

		minetest.register_node("mymod:test_display_node", {
			...
			paramtype2 = "wallmounted",
			...
			display_entities = {
				["mymod:entity1"] = { depth = -0.3, 
					on_display_update = my_display_update1},
				["mymod:entity1"] = { depth = -0.2, 
					on_display_update = my_display_update2},
			},
			...
			on_place = display_lib.on_place,
			on_construct = display_lib.on_construct,
			on_destruct = display_lib.on_destruct,
			on_rotate = display_lib.on_rotate,
			...
		})



