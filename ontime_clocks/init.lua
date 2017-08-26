--[[
    ontime_clocks mod for Minetest - Clock nodes displaying ingame time 
    (c) Pierre-Yves Rollo

    This file is part of ontime_clocks.

    ontime_clocks is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ontime_clocks is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ontime_clocks.  If not, see <http://www.gnu.org/licenses/>.
--]]

ontime_clocks = {}
ontime_clocks.name = minetest.get_current_modname()
ontime_clocks.path = minetest.get_modpath(ontime_clocks.name)

-- Load support for intllib.
local S, NS = dofile(ontime_clocks.path.."/intllib.lua")
ontime_clocks.intllib = S

dofile(ontime_clocks.path.."/common.lua")
dofile(ontime_clocks.path.."/nodes.lua")
dofile(ontime_clocks.path.."/crafts.lua")
