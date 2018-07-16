--[[
    boards mod for Minetest. Black boards with text on it.
    (c) Pierre-Yves Rollo

    This file is part of boards.

    boards is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    boards is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with boards.  If not, see <http://www.gnu.org/licenses/>.
--]]

boards = {}
boards.name = minetest.get_current_modname()
boards.path = minetest.get_modpath(boards.name)

-- Load support for intllib.
local S, NS = dofile(boards.path.."/intllib.lua")
boards.intllib = S
local F = function(...) return minetest.formspec_escape(S(...)) end

-- Load font
dofile(boards.path.."/font_tinycurs.lua")

local function set_formspec(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec",
		"size[6,4]"..default.gui_bg..default.gui_bg_img..default.gui_slots..
		"textarea[0.5,0.7;5.5,3;display_text;"..F("Text")..";${display_text}]"..
		"button_exit[3,3.5;2,1;ok;"..F("Write").."]"..
		"button_exit[1,3.5;2,1;wipe;"..F("Wipe").."]")
end

-- On boards, everyone is allowed to write and wipe
local function on_receive_fields(pos, formname, fields, player)
	if fields then
		if fields.ok or fields.key_enter then
			signs_api.set_display_text(pos, fields.display_text, fields.font)
		end
		if fields.wipe then
			signs_api.set_display_text(pos, "", fields.font)
		end
	end
end

models = {
	black_board = {
		depth = 1/16, width = 1, height = 1,
		entity_fields = {
			top = -1/32,
			size = { x = 1, y = 15/16 },
			maxlines = 5,
			color = "#fff",
			font_name = "tinycurs",
			valign = "top",
		},
		node_fields = {
			description = S("Black board"),
			tiles = { "default_wood.png", "default_wood.png",
				"default_wood.png", "default_wood.png",
				"default_wood.png", "board_black_front.png" },
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, 7/16, 0.5, 0.5, 0.5},
					{-0.5, -7/16, 6/16, 0.5, -0.5, 7/16}
				},
			},
			on_construct = function(pos)
				set_formspec(pos)
				display_api.on_construct(pos)
			end,
			on_receive_fields = on_receive_fields,
		},
	},
	green_board = {
		depth = 1/16, width = 1, height = 1,
		entity_fields = {
			top = -1/32,
			size = { x = 1, y = 15/16 },
			maxlines = 5,
			color = "#fff",
			font_name = "tinycurs",
			valign = "top",
		},
		node_fields = {
			description = S("Green board"),
			tiles = { "default_wood.png", "default_wood.png",
				"default_wood.png", "default_wood.png",
				"default_wood.png", "board_green_front.png" },
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, 7/16, 0.5, 0.5, 0.5},
					{-0.5, -7/16, 6/16, 0.5, -0.5, 7/16}
				},
			},
			on_construct = function(pos)
				set_formspec(pos)
				display_api.on_construct(pos)
			end,
			on_receive_fields = on_receive_fields,
		},
	},
}

-- Node registration
for name, model in pairs(models)
do
	signs_api.register_sign("boards", name, model)
end

-- Recipes
minetest.register_craft(
	{
		output = "boards:black_board",
		recipe = {
			{"group:wood", "group:stone", "dye:black"},
		}		
	})

minetest.register_craft(
	{
		output = "boards:green_board",
		recipe = {
			{"group:wood", "group:stone", "dye:dark_green"},
		}		
	})

