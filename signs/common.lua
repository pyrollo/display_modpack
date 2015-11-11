local font = {}
signs.font_height = 10

-- Get png width, suposing png width is less than 256 (it is the case for all font textures)
local function get_png_width(filename)
	local file=assert(io.open(filename,"rb"))
	-- All font png are smaller than 256x256 --> read only last byte
	file:seek("set",19)
	local w = file:read(1)
	file:close()
	return w:byte()
end

-- Computes line width for a given font height and text
function signs.get_line_width(text)
	local char
	local width = 0

	for p=1,#text
	do
		char = text:sub(p,p):byte()
		if font[char] then
			width = width + font[char].width
		end
	end

	return width
end

--- Builds texture part for a text line
-- @param text Text to be rendered
-- @param x Starting x position in texture
-- @param width Width of the texture (extra text is not rendered)
-- @param y Vertical position of the line in texture
-- @return Texture string
function signs.make_line_texture(text, x, width, y)
	local char

	local texture = ""

	for p=1,#text
	do
		char = text:sub(p,p):byte()
		if font[char] then
			-- Add image only if it is visible (at least partly)
			if x + font[char].width >= 0 and x <= width then
				texture = texture..string.format(":%d,%d=%s", x, y, font[char].filename)
			end
			x = x + font[char].width
		end
	end
	return texture
end

local function split_lines(text, maxlines)
	local splits = text:split("\n")
	if maxlines then
		local lines = {}
		for num = 1,maxlines do
			lines[num] = splits[num]
		end
		return lines
	else
		return splits
	end
end

function signs.on_display_update(pos, objref)
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("display_text")

	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.sign_model then
		local model = signs.sign_models[ndef.sign_model]
		local lines = split_lines(text, model.maxlines)

		local texturew = model.width/model.xscale
		local textureh = model.height/model.yscale

		local texture = ""

		local y
		if model.valing == "top" then
			y = signs.font_height / 2
		else		
			y = (textureh - signs.font_height * #lines) / 2 + 1 
		end

		for _, line in pairs(lines) do
			texture = texture..signs.make_line_texture(line, 
				(texturew - signs.get_line_width(line)) / 2, 
				texturew, y)
			y = y + signs.font_height
		end

		local texture = string.format("[combine:%dx%d", texturew, textureh)..texture
		if model.color then texture = texture.."^[colorize:"..model.color end

		objref:set_properties({ textures={texture}, visual_size = {x=model.width, y=model.height}})
	end
end

function signs.set_formspec(pos)
	local meta = minetest.get_meta(pos)
	local ndef = minetest.registered_nodes[minetest.get_node(pos).name]
	if ndef and ndef.sign_model then
		local model = signs.sign_models[ndef.sign_model]
		local formspec

		if model.maxlines == 1 then
			formspec = "size[6,3]"..
				"field[0.5,0.7;5.5,1;display_text;Displayed text;${display_text}]"..
				"button_exit[2,2;2,1;ok;Write]"
		else
			local extralabel = ""
			if model.maxlines then
				extralabel = " (first "..model.maxlines.." lines only)"
			end

			formspec = "size[6,4]"..
				"textarea[0.5,0.7;5.5,2;display_text;Displayed text"..extralabel..";${display_text}]"..
				"button_exit[2,3;2,1;ok;Write]"
		end

		meta:set_string("formspec", formspec)
	end
end

function signs.on_receive_fields(pos, formname, fields, player)
	if not minetest.is_protected(pos, player:get_player_name()) then
		local meta = minetest.get_meta(pos)
		if fields and fields.ok then
			meta:set_string("display_text", fields.display_text)
			meta:set_string("infotext", "\""..fields.display_text.."\"")
			display_lib.update_entities(pos)
		end
	end
end

-- On place callback for direction signs 
-- (chooses which sign according to look direction)
function signs.on_place_direction(itemstack, placer, pointed_thing)
	local above = pointed_thing.above
	local under = pointed_thing.under
	local wdir = minetest.dir_to_wallmounted(
				{x = under.x - above.x,
				 y = under.y - above.y,
				 z = under.z - above.z})
	
	local dir = placer:get_look_dir()

	if wdir == 0 or wdir == 1 then
		wdir = minetest.dir_to_wallmounted({x=dir.x, y=0, z=dir.z})
	end

	local name = itemstack:get_name()

	-- Only for direction signs (ending with _right)
	if name:sub(-string.len("_right")) == "_right" then
		name = name:sub(1, -string.len("_right"))

		local test = {0, dir.z, -dir.z, -dir.x, dir.x}
		if test[wdir] > 0 then
			itemstack:set_name(name.."left")
		end
		itemstack = minetest.item_place(itemstack, placer, pointed_thing, wdir)
		itemstack:set_name(name.."right")

		return itemstack
	else
		return minetest.item_place(itemstack, placer, pointed_thing, wdir)
	end
end

-- On_rotate (screwdriver) callback for direction signs
function signs.on_rotate_direction(pos, node, user, mode, new_param2)
	if mode == screwdriver.ROTATE_AXIS then 
		local name
		if node.name:sub(-string.len("_right")) == "_right" then
			name = node.name:sub(1, -string.len("_right")).."left"
		end
		if node.name:sub(-string.len("_left")) == "_left" then
			name = node.name:sub(1, -string.len("_left")).."right"
		end

		if name then
			minetest.swap_node(pos, {name = name, param1 = node.param1, param2 = node.param2})
		end
		return false
	else
		return display_lib.on_rotate(pos, node, user, mode, new_param2)
	end
end

-- Populate fonts table
local w, filename
for charnum=32,126 do
	filename = string.format("signs_%02x.png", charnum)
	w = get_png_width(signs.path.."/textures/"..filename)
	font[charnum] = {filename=filename, width=w}
end

-- Generic callback for show_formspec displayed formspecs
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local found, _, mod, node_name, pos = formname:find("([%w_]+):([%w_]+)@(.+)")

	if found then
		if mod ~= 'signs' then return end

		local ndef = minetest.registered_nodes[mod..":"..node_name]

		if ndef and ndef.on_receive_fields then
			ndef.on_receive_fields(minetest.string_to_pos(pos), formname, fields, player)
		end
	end
end)
