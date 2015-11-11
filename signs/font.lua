
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

-- Populate fonts table
local w, filename
for charnum=32,126 do
	filename = string.format("signs_%02x.png", charnum)
	w = get_png_width(signs.path.."/textures/"..filename)
	font[charnum] = {filename=filename, width=w}
end

