minetest.register_craft({
	output = 'signs:wooden_right',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', ''},
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

