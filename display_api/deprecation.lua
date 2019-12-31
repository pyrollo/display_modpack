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

-- Deprecation

function deprecated_group(deprecated_group, replacement_group)
	for name, ndef in pairs(minetest.registered_nodes) do
		if ndef.groups and ndef.groups[deprecated_group] then
			minetest.log("warning", string.format(
				'Node %s belongs to deprecated "%s" group which should be replaced with new "%s" group.',
				name, deprecated_group, replacement_group))
		end
	end
end

function deprecated_global_table(deprecated_global_name, replacement_global_name)
	assert(type(deprecated_global_name) == 'string', "deprecated_global_name should be a string.")
	assert(type(replacement_global_name) == 'string', "replacement_global_name should be a string.")
	assert(deprecated_global_name ~= '', "deprecated_global_name should not be empty.")
	assert(replacement_global_name ~= '', "replacement_global_name should not be empty.")
	assert(rawget(_G, deprecated_global_name) == nil, "deprecated global does not exist.")
	if _G[replacement_global_name] == nil then
		minetest.log('warning', string.format(
			'Replacement global "%s" does not exists.', replacement_global_name))
		return
	end
	local meta = {
		deprecated = deprecated_global_name,
		replacement = replacement_global_name,
		__index = function(table, key)
			local meta = getmetatable(table)
			local dbg = debug.getinfo(2, "lS")
			minetest.log("warning", string.format(
				'Accessing deprecated "%s" table, "%s" should be used instead (%s:%d).',
				meta.deprecated, meta.replacement, (dbg.short_src or 'unknown'),
				(dbg.currentline or 0)))
			return _G[meta.replacement][key]
		end,
		__newindex = function(table, key, value)
			local meta = getmetatable(table)
			local dbg = debug.getinfo(2, "lS")
			minetest.log("warning", string.format(
				'Accessing deprecated "%s" table, "%s" should be used instead (%s:%d).',
				meta.deprecated, meta.replacement, (dbg.short_src or 'unknown'),
				(dbg.currentline or 0)))
			_G[meta.replacement][key]=value
		end,
	}
	rawset(_G, deprecated_global_name, {})
	setmetatable(_G[deprecated_global_name], meta)
end


-- deprecated(1) -- December 2018 - Deprecation of groups display_modpack_node and display_lib_node
-- Group to be removed from display API register_lbm
minetest.after(0, function()
	deprecated_group("display_modpack_node", "display_api")
	deprecated_group("display_lib_node", "display_api")
end)

-- deprecated(2) -- December 2018 - Deprecation of display_lib
deprecated_global_table('display_lib', 'display_api')
