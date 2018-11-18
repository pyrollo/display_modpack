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

local modname = minetest.get_current_modname()

local contexts = {}

minetest.register_on_leaveplayer(function(player)
	if minetest.is_player(player) then
		contexts[player:get_player_name()] = nil
	end
end)

local function get_context(playername)
	if not contexts[playername] then
		contexts[playername] = { playername = playername }
	end
	return contexts[playername]
end

-- Show node formspec functions
local function show_node_formspec(playername, pos)
	local meta = minetest.get_meta(pos)

	-- Decontextualize formspec
	local fs = meta:get_string('formspec')

	if not fs then
		return
	end

	-- Change context and currrent_name references to nodemeta references
	-- Change context and currrent_name references to nodemeta references
	local nodemeta = string.format("nodemeta:%i,%i,%i", pos.x, pos.y ,pos.z)
	fs = fs:gsub("current_name", nodemeta)
	fs = fs:gsub("context", nodemeta)

	-- Change all ${} to their corresponding metadata values
	local s, e
	repeat
		s, e = fs:find('%${.*}')
		if s and e then
			fs = fs:sub(1, s-1)..
				minetest.formspec_escape(meta:get_string(fs:sub(s+2,e-1)))..
				fs:sub(e+1)
		end
	until s == nil

	local context = get_context(playername)
	context.node_pos = pos

	-- Find node on_receive_fields
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.on_receive_fields then
		context.on_receive_fields = ndef.on_receive_fields
	end

	-- Show formspec
	minetest.show_formspec(playername, modname..':context_formspec', fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= modname..':context_formspec' then
		return
	end

	if not minetest.is_player(player) then
		return true
	end

	local context = get_context(player:get_player_name())
	if context.on_receive_fields then
		context.on_receive_fields(context.pos, '', fields, player)
	end
	return true
end)

-- Specific functions

local function show_font_formspec(playername)
	local context = get_context(playername)
	local fonts = {}
	for name, _ in pairs(font_api.registered_fonts) do
		fonts[#fonts+1] = name
	end
	table.sort(fonts)

	local fs = 'size[4,'..(#fonts + 0.8)..']'
		..default.gui_bg..default.gui_bg_img..default.gui_slots
		..'button_exit[0,'..(#fonts)..';4,1;cancel;Cancel]'

	for line = 1, #fonts do
		local font = font_api.get_font(fonts[line])
		fs = fs..'image[0.1,'..(line-0.9)..';4.5,0.8;'
		..font:make_text_texture(font.name, font:get_height()*5,
			font:get_height()*1.2, 1, "center", "top", "#fff")
		..']button_exit[0,'..(line-1)..';4,1;font_'..font.name..';]'
	end
	minetest.show_formspec(context.playername, modname..':font_list', fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= modname..':font_list' then
		return
	end

	if not minetest.is_player(player) then
		return true
	end

	local playername = player:get_player_name()
	local context = get_context(playername)

	if minetest.is_protected(context.pos, playername) then
		return true
	end

	if fields.quit == 'true' then
		for name, _ in pairs(font_api.registered_fonts) do
			if fields['font_'..name] then
				local meta = minetest.get_meta(context.pos)
				meta:set_string("font", name)
				display_api.update_entities(context.pos)
			end
		end
		-- Using after to avoid the "double close" bug
		minetest.after(0, show_node_formspec, playername, context.pos)
	end
	return true
end)

function font_api.show_font_list_from_pos(player, pos)
	if minetest.is_player(player) then
		local context = get_context(player:get_player_name())
		context.pos = pos
		show_font_formspec(player:get_player_name())
	end
end
