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

local S = signs.intllib
local F = function(...) return minetest.formspec_escape(S(...)) end


--Backwards compatibility functions

signs.set_display_text = function(...)
	minetest.log("warning", "signs.set_display_text() is deprecated, please use signs_api.set_display_text() instead.")
	return signs_api.set_display_text(...)
end

signs.set_formspec = function(...)
	minetest.log("warning", "signs.set_formspec() is deprecated, please use signs_api.set_formspec() instead.")
	return  signs_api.set_formspec(...)
end

signs.on_receive_fields = function(...)
	minetest.log("warning", "signs.on_receive_fields() is deprecated, please use signs_api.on_receive_fields() instead.")
	return  signs_api.on_receive_fields(...)
end

signs.on_place_direction = function(...)
	minetest.log("warning", "signs.on_place_direction() is deprecated, please use signs_api.on_place_direction() instead.")
	return  signs_api.on_place_direction(...)
end

signs.on_rotate = function(...)
	minetest.log("warning", "signs.on_rotate() is deprecated, please use signs_api.on_rotate() instead.")
	return  signs_api.on_rotate(...)
end

signs.register_sign = function(...)
	minetest.log("warning", "signs.register_sign() is deprecated, please use signs_api.register_sign() instead.")
	return  signs_api.register_sign(...)
end


-- Generic callback for show_formspec displayed formspecs of "sign" mod

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local found, _, mod, node_name, pos = formname:find("^([%w_]+):([%w_]+)@([^:]+)")
	if found then
		if mod ~= 'signs' then return end

		local ndef = minetest.registered_nodes[mod..":"..node_name]

		if ndef and ndef.on_receive_fields then
			ndef.on_receive_fields(minetest.string_to_pos(pos), formname, fields, player)
		end
	end
end)
