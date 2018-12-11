# Display API

This library's purpose is to ease creation of nodes with one or more displays on sides. For example, signs and clocks. Display can be dynamic and/or different for each node instance.

**Limitations**: This lib uses entities to draw display. This means display has to be vertical. So display nodes rotation are limitated to "upside up" positions.

**Dependancies**:default

**License**: LGPLv2

**API**: See [API.md](https://github.com/pyrollo/display_modpack/blob/master/display_api/API.md) document please.

For more information, see the [forum topic](https://forum.minetest.net/viewtopic.php?t=19365) at the Minetest forums.

## Deprecation notice (for modders)

### December 2018
Following objects are deprecated, shows a warning in log when used:
* `display_modpack_node` group (use `display_api` group instead);
* `display_lib_node` group (use `display_api` group instead);
* `display_lib` global table (use `display_api` global table instead);

These objects will be removed in the future.
