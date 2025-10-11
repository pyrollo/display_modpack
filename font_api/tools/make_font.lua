--
-- A font mod generator for font_api
--

-- This files generates only code and textures - should not be translated


-- TODO : detect and manage fixed width fonts

--
-- Dependancies check
--

local function check(cmd, msg)
	if os.execute(cmd .. " > /dev/null 2>&1") then
		return true
	else
		print(msg)
	end
end

if
	not check("convert --version", "Error: This program requires convert from ImageMagick!") or
	not check("identify --version", "Error: This program requires identify from ImageMagick!") or
	not check("ttx --version", "Error: This program requires ttx from FontTools!") or
	not check("xmlstarlet --version", "Error: This program requires xmlstarlet!")
then
	print("Please fix above problem and retry.")
	os.exit(1)
end

--
-- Argument & parameters management
--

local function usage()
	print (arg[0] .. " takes two arguments:")
	print (" - parameter file")
	print (" - destination path")
end

if #arg ~= 2 then
	usage()
	os.exit(1)
end

print("Reading paramaters.")
dofile(arg[1])

local mod_dir = arg[2]
if os.execute("[ -d " .. mod_dir .. " ]") then
	print ("Directory " .. mod_dir .. " already exists!")
--	os.exit(1)
end
os.execute("mkdir -p " .. mod_dir .. "/textures")

--
-- Available tile sizes management
--

local function compute_tile_sizes(texture_size)
	results = {}
	for size = 1, texture_size do
		if texture_size % size == 0 then
			table.insert(results, size)
		end
	end
	return results
end

-- This will give enough tile width combinations (360 is 2 * 2 * 2 * 3 * 3 * 5)
local tile_widths = compute_tile_sizes(360)

-- Table width has to be sorted
table.sort(tile_widths)
local texture_width = tile_widths[#tile_widths]

-- Rounds glyph width up to available tile width (first width larger than given one)
local function tile_width(width)
	for _, w in ipairs(tile_widths) do
		if width < w then
			return w
		end
	end
	return texture_width
end

--
-- Helper functions
--

-- Issue an OS command and get its result
local function command(cmd)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	return s
end

-- Escape chars that could harm commands
local function escape(char) 
	if char == "\\" then return "\\\\\\\\" end
	if char == "\"" then return "\\\"" end
	if char == "`"  then return "\\`" end
	return char
end

--
-- Things start here
--

-- Measures a glyph, returs its height and width in pixels
local function measure(font, codepoint)
	local char = utf8.char(codepoint)

	local cmd = string.format(
		"convert -font \"%s\" -pointsize %d label:\"%s\" -define trim:edges=east,west -trim info:",
		font.file, font.glyphs_height, escape(char)
	)
	local _, _, w, h = string.find(command(cmd), "([0-9]+)x([0-9]+)" )
	return tonumber(w), tonumber(h)
end

-- Read all available codepoints from ttf file
local function read_available_codepoints(file)
	-- Takes only first cmap table found.
	-- TODO: Should choose table according to platformID (3 else 0 else 2)
	-- (see https://stackoverflow.com/a/29424838)
	local cmd, errmsg, status = io.popen(string.format(
		"ttx -o - \"%s\" 2>/dev/null | " ..
		"xmlstarlet sel -t -v \"//*[starts-with(name(), 'cmap_format_')][1]/map/@code\" | " ..
		"sort -u",
		file), 'r')

	if cmd == nil then
		print(string.format(
			"Could not open font file %s:\n%s", file, errmsg))
		os.exit(status)
	end

	local codepoints = {}
	local codepoint = cmd:read("*line")
	while codepoint do
		codepoints[tonumber(codepoint)] = true
		codepoint = cmd:read("*line")
	end
	cmd:close()

	return codepoints
end

-- Add codepoints to a font
local function add_codepoints(font, from, to)
	for codepoint = from, to do
		if font.cp[codepoint] then
			-- Glyph size
			local w, h = measure(font, codepoint)
			if h > font.glyphs_height then font.glyphs_height = h end

			-- Detect and discard eventual buggy glyphs (may be spaces)
			if h > 1 then
				font.glyph_widths[codepoint] = w

				-- Tile width
				local tile_w = tile_width(w)
				if font.by_width[tile_w] == nil then
					font.by_width[tile_w] = {}
					table.insert(font.tile_widths, tile_w)
				end
				table.insert(font.by_width[tile_w], codepoint)
			end
		end
	end
end

-- Make font texture
-- Font must have all its codepoints added
local function make_final_texture(font)
	local texture_file = string.format("%s/textures/font_%s.png",
		mod_dir, font.name)

	-- We start with a single line
	font.texture_height = font.glyphs_height

	-- Characteristics of [sheet:NxM:x,y
	-- M is always the same and depends on font and texture height.
	font.glyph_xs = {} -- x for each glyph
	font.glyph_ys = {} -- y for each glyph
	font.glyph_ns = {} -- n of tiles in sheet for each glyph (=texturewidth / tilewidth)

	local x = 0 -- cursor x
	local glyph_y = 0

	table.sort(font.tile_widths)

	-- Compute positions
	for _, tile_width in ipairs(font.tile_widths) do
		for _, codepoint in ipairs(font.by_width[tile_width]) do
			local glyph_x = math.ceil(x / tile_width)
			x = glyph_x * tile_width
			if x + tile_width > texture_width then -- no space left on current line
				x = 0
				glyph_x = 0
				glyph_y = glyph_y + 1
				font.texture_height = font.texture_height + font.glyphs_height
			end
			font.glyph_xs[codepoint] = glyph_x
			font.glyph_ys[codepoint] = glyph_y
			font.glyph_ns[codepoint] = math.floor(texture_width / tile_width)
			x = x + tile_width
		end
	end

	-- Compose texture
	command(string.format(
		"convert -size %dx%d xc:transparent %s",
		texture_width, font.texture_height, texture_file
	))

	for codepoint, n in pairs(font.glyph_ns) do
		local w = math.floor(texture_width / n)
		local x = w * font.glyph_xs[codepoint]
		local y = font.glyphs_height * font.glyph_ys[codepoint]
		
		local cmd
		-- Subtexture subcommand
		if codepoint == 0 then
			-- The "unknown" char
  			cmd = string.format(
				"convert %s" ..
				" -stroke black -fill transparent -strokewidth 1 " ..
				" -draw \"rectangle %d,%d %d,%d\" %s",
				texture_file, x, y, x + w, y + font.glyphs_height, texture_file
			)
		else
			-- Other glyhp chars
			cmd = string.format(
				"convert %s \\(" ..
				" -background none -font \"%s\" -pointsize %d label:\"%s\"" .. 
				" -define trim:edges=east,west -trim" ..
				" -repage +%d+%d \\) -flatten %s",
				texture_file, font.file, font.pointsize, escape(utf8.char(codepoint)),
				x, y, texture_file
			)
			
		end
		command(cmd)
	end

    command(string.format("convert %s -channel alpha -threshold 50%% %s", texture_file, texture_file))
end

local function process_font(font)

	-- Defaults
	font.label = font.label or font.name:gsub("^%l", string.upper)
    font.margin_top = font.margin_top or 0
	font.line_spacing = font.line_spacing or 0
	font.char_spacing = font.char_spacing or 0

	print(string.format("Processing font \"%s\" (%s)", font.label, font.name))

	-- Computed values
	font.by_width = {} -- Codepoints by tile width
	font.tile_widths = {} -- Used tile widths
	font.glyph_widths = {} -- Exact width of reach glyph
	font.glyphs_height = 0 -- Max height of all glyphs

	print("Read available glyphs")

	-- Available codepoints from file
	font.cp = read_available_codepoints(font.file)

	print("Compute glyphs properties")

	-- Special char: unknown char
	-- We use size of glyph "0" (rounded) but it would be better to get size from ttx

	-- TODO: We could get information from ttx:
	--   <mtx> gives a width always divisible by 125 for metro font (check if its somehow proportional to what magick gives)

	local w = tile_width(measure(font, 0x0030))
	font.glyph_widths[0] = w
	font.by_width[w] = { 0 }
	font.tile_widths = { w }

	-- Mandatory codepoints (ASCII)
	add_codepoints(font, 0x0021, 0x007f)

	-- Extra codepoints
	if font.codepoints then
		for _, range in ipairs(font.codepoints) do
			add_codepoints(font, range.from, range.to)
		end
	end

	print("Create final texture")

	make_final_texture(font)

	-- Add invisible chars : Spaces
	-- TODO: Should be computed from ttx
	-- TODO: manage half/quater spaces
	font.glyph_widths[0x0020] = font.glyph_widths[0x0030]

end

local function get_font_registration_lua(font)

	local glyphs = "{"
	local curlinesize = 1000

	for codepoint, w in pairs(font.glyph_widths) do
		local glyph
		local x = font.glyph_xs[codepoint]
		local y = font.glyph_ys[codepoint]
		local n = font.glyph_ns[codepoint]
		if x ~= nil and y ~=nil and n ~= nil then
			glyph = string.format("[%d] = { %d, %d, %d, %d },", codepoint, w, n, x, y)
		else
			glyph = string.format("[%d] = { %d },", codepoint, w)
		end

		curlinesize = curlinesize + glyph:len() + 1
		if curlinesize > 80 then
			glyphs = glyphs .. "\n\t\t\t" ..  glyph
			curlinesize = 12 + glyph:len()
		else
			glyphs = glyphs .. " " .. glyph
		end
	end
	glyphs = glyphs .. "\n\t\t}"

	return string.format([[
-- Font generated from file %s with pointsize %d
font_api.register_font(
	'%s',
	{
		version = 2,
		default = true,
		margintop = 3,
		linespacing = -2,
		charspacing = 2,
		texture_height = %d,
		glyphs_height = %d,
		glyphs = %s,
	}
)
]],	font.file, font.pointsize, font.name, font.texture_height, font.glyphs_height, glyphs)
end

--
-- Main code
--

for _, font in ipairs(params.fonts) do
	process_font(font)
end

-- Write init.lua
local file = io.open(mod_dir .. "/init.lua", "w")

file:write(string.format([[
--
-- %s: A font mod for font_api
--
-- This file was generated by `%s` on %s.
--

]], params.mod_name, arg[0], os.date("%Y-%m-%d at %H:%M")
))

for _, font in ipairs(params.fonts) do
	file:write(get_font_registration_lua(font))
end

file:close()

--
-- Write mod.conf
--

local file = io.open(mod_dir .. "/mod.conf", "w")
file:write(string.format([[
name = %s
title = %s
description = %s
depends = font_api
]], params.mod_name, params.mod_title, params.mod_description))


