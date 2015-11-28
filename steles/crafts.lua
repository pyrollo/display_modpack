for _, material in ipairs(steles.materials) do
	local parts = material:split(":")

	minetest.register_craft({
		output = 'steles:'..parts[2]..'_stele 4',
		recipe = {
			{'', material, ''},
			{'', 'dye:black', ''},
			{material, material, material},
		}
	})

end
