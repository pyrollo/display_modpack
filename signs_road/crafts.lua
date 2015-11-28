minetest.register_craft({
	output = 'signs_road:blue_street',
	recipe = {
		{'dye:blue', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:green_street',
	recipe = {
		{'dye:green', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs_road:black_right',
	recipe = {
		{'dye:black', 'dye:white', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'', '', ''},
	}
})

