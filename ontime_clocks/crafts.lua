
minetest.register_craft({
	output = 'ontime_clocks:green_digital',
	recipe = {
		{'', 'dye:green', ''},
		{'default:glass', 'default:mese_crystal', 'default:glass'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:red_digital',
	recipe = {
		{'', 'dye:red', ''},
		{'default:glass', 'default:mese_crystal', 'default:glass'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:white',
	recipe = {
		{'default:steel_ingot', 'default:paper', 'default:steel_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_black',
	recipe = {
		{'default:steel_ingot', 'dye:black', 'default:steel_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_gold',
	recipe = {
		{'default:gold_ingot', '', 'default:gold_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'ontime_clocks:frameless_white',
	recipe = {
		{'default:steel_ingot', 'dye:white', 'default:steel_ingot'},
		{'', 'default:mese_crystal', ''},
		{'', '', ''},
	}
})


