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

-- Context management functions (surely many improvements to do)

local contexts = {}

local function get_player_name(player)
	if type(player) == 'string' then return player end
	if type(player) == 'userdata' and player.get_player_name then
		return player:get_player_name()
	end
	minetest.log('warning',	'['..modname..'] get_player_name could not identify player.')
end

minetest.register_on_leaveplayer(function(player)
	local playername = get_player_name(player)
	if playername then contexts[playername] = nil end
end)

local function new_context(player, context)
	local playername = get_player_name(player)
	if playername then
		contexts[playername] = context
		contexts[playername].playername = playername
		return contexts[playername]
    end
end

local function get_context(player)
	local playername = get_player_name(player)
	if playername then
		if contexts[playername] then
			return contexts[playername]
		else
			minetest.log('warning', '['..modname..'] Context not found for player "'..playername..'"')
		end
	end
end

local function update_context(player, changes)
	local playername = get_player_name(player)
	if playername then
		if not contexts[playername] then
			contexts[playername] = { playername = playername }
		end
		for key, value in pairs(changes) do
			contexts[playername][key] = value
		end
	end
end

-- Show node formspec functions

local function show_node_formspec(player, pos)
	local meta = minetest.get_meta(pos)
	local playername = get_player_name(player)

	-- Decontextualize formspec
	local fs = meta:get_string('formspec')

	-- Change context and currrent_name references to nodemeta references
	fs = fs:gsub("current_name", "nodemeta:"..pos.x..","..pos.y..","..pos.z)
	fs = fs:gsub("context", "nodemeta:"..pos.x..","..pos.y..","..pos.z)

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

	-- Find node on_receive_fields
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]

	if ndef and ndef.on_receive_fields then
		update_context(player, { on_receive_fields = ndef.on_receive_fields } )
	end
	update_context(player, { node_pos = pos } )

	-- Show formspec
	minetest.show_formspec(playername, modname..':context_formspec', fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == modname..':context_formspec' then
		local context = get_context(player)
		if context == nil then return end

		if context.on_receive_fields then
			context.on_receive_fields(context.pos, '', fields, player)
		end
	end
end)

-- Specific functions

local function font_list_prepare()
	local list = {}
	for name, _ in pairs(font_api.registered_fonts) do
		list[#list+1] = name
	end
	table.sort(list)
	return list
end

local function show_fs(player)
	local context = get_context(player)
	if context == nil then return end
	local fonts = font_list_prepare()

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
	if formname == modname..':font_list' then
		local context = get_context(player)
		if context == nil then return end

		if fields.quit == 'true' then
			for name, _ in pairs(font_api.registered_fonts) do
				if fields['font_'..name] then
					local meta = minetest.get_meta(context.pos)
					meta:set_string("font", name)
					display_api.update_entities(context.pos)
				end
			end

			-- Using after to avoid the "double close" bug
			minetest.after(0, show_node_formspec, player, context.pos)
		end
	end
end)

function font_api.show_font_list(player, pos)
	new_context(player, { pos = pos })
	show_fs(player)
end
