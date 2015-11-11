minetest.register_craft({
	output = 'signs:blue_street',
	recipe = {
		{'dye:blue', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs:green_street',
	recipe = {
		{'dye:green', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs:wooden_right',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs:black_right',
	recipe = {
		{'dye:black', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs:poster',
	recipe = {
		{'default:paper', 'default:paper', ''},
		{'default:paper', 'default:paper', ''},
		{'default:paper', 'default:paper', ''},
	}
})

