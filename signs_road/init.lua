--[[
    signs_road mod for Minetest - Various road signs with text displayed
    on.
    (c) Pierre-Yves Rollo

    This file is part of signs_road.

    signs_road is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs_road is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs_road.  If not, see <http://www.gnu.org/licenses/>.
--]]

signs_road = {}
signs_road.name = minetest.get_current_modname()
signs_road.path = minetest.get_modpath(signs_road.name)

-- Load support for intllib.
local S, NS = dofile(signs_road.path.."/intllib.lua")
signs_road.intllib = S

dofile(signs_road.path.."/nodes.lua")
dofile(signs_road.path.."/crafts.lua")
dofile(signs_road.path.."/compatibility.lua")





