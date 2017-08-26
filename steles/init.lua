--[[
    steles mod for Minetest. Steles / graves with text on it.
    (c) Pierre-Yves Rollo

    This file is part of steles.

    steles is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    steles is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with steles.  If not, see <http://www.gnu.org/licenses/>.
--]]

steles = {}
steles.name = minetest.get_current_modname()
steles.path = minetest.get_modpath(steles.name)

-- Load support for intllib.
local S, NS = dofile(steles.path.."/intllib.lua")
steles.intllib = S

dofile(steles.path.."/config.lua")
dofile(steles.path.."/nodes.lua")
dofile(steles.path.."/crafts.lua")
