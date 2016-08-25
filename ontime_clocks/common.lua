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

-- Entity for time display
display_lib.register_display_entity("ontime_clocks:display")

function ontime_clocks.get_h24()
	return math.floor(minetest.get_timeofday()*24)%24
end

function ontime_clocks.get_h12()
	return math.floor(minetest.get_timeofday()*24)%12
end

function ontime_clocks.get_m12()
	return math.floor(minetest.get_timeofday()*288)%12
end

function ontime_clocks.get_digital_properties(color_off, color_on, hour, minute)
	return 
	{
		textures={"ontime_clocks_digital_background.png^[colorize:"..color_off
			.."^([combine:21x7"
			..":0,"..(-7*(math.floor(hour/10))).."=ontime_clocks_digital_digit.png"
			..":5,"..(-7*(hour%10)).."=ontime_clocks_digital_digit.png"
			..":9,-70=ontime_clocks_digital_digit.png"
			..":12,"..(-7*(math.floor(minute/2))).."=ontime_clocks_digital_digit.png"
			..":17,"..(-35*(minute%2)).."=ontime_clocks_digital_digit.png"
			.."^[colorize:"..color_on..")"},
		visual_size = {x=21/32, y=7/32}
	}
end

function ontime_clocks.get_needles_properties(color, size, hour, minute)
	return
	{
		textures={"[combine:"..size.."x"..size	
			..":0,"..(-size*hour).."=ontime_clocks_needle_h"..size..".png"
			..":0,"..(-size*minute).."=ontime_clocks_needle_m"..size..".png"
			.."^[colorize:"..color},
		visual_size = {x=size/64, y=size/64}
	}
end

