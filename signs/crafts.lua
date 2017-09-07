minetest.register_craft({
	output = 'signs:wooden_right_sign',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', ''},
		{'', '', ''},
	}
})

minetest.register_craft({
	output = 'signs:paper_poster',
	recipe = {
		{'default:paper', 'default:paper', ''},
		{'default:paper', 'default:paper', ''},
		{'default:paper', 'default:paper', ''},
	}
})

