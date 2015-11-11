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

