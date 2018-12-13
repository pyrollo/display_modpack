minetest.register_craft({
	output = 'signs:wooden_right_sign',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'dye:black'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs:wooden_right_sign',
	type = 'shapeless',
	recipe = { 'signs:wooden_long_sign' }
})

minetest.register_craft({
	output = 'signs:wooden_long_sign',
	recipe = {
		{'group:wood', 'dye:black',  'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs:wooden_long_sign',
	type = 'shapeless',
	recipe = { 'signs:wooden_right_sign' }
})

minetest.register_craft({
	output = 'signs:wooden_sign',
	recipe = {
		{'', 'dye:black',  ''},
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	output = 'signs:paper_poster',
	recipe = {
		{'default:paper', 'default:paper', 'dye:black'},
		{'default:paper', 'default:paper', ''},
		{'default:paper', 'default:paper', ''},
	}
})

minetest.register_craft({
	output = 'signs:label_small',
	recipe = {
		{'default:paper', 'dye:black'},
	}
})

minetest.register_craft({
	output = 'signs:label_medium',
	recipe = {
		{'default:paper', 'default:paper', 'dye:black'},
	}
})
