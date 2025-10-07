--
-- A font mod generator for font_api
--

-- This files generates only code and textures - should not be translated


-- TODO : detect and manage fixed width fonts

--
-- Argument management
--

local function usage()
	print (arg[0].." takes tree arguments:")
	print (" - font file name")
	print (" - wanted font name")
	print (" - wanted font height")
end

if #arg ~= 3 then
	usage()
	os.exit(1)
end

local fontfile=arg[1]
local fontname=arg[2]
local fontsize=arg[3]

local modname = fontname

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
	not check("ttx --version", "Error: This program requires ttx from FontTools!")
then
	print("Please fix above problem and retry.")
	os.exit(1)
end

--
-- Prepare output directory
--

-- TODO: we should be able to choose basedir
local moddir = "font_" .. fontname

if os.execute("[ -d " .. moddir .. " ]") then
	print ("Directory " .. moddir .. " already exists!")
--	os.exit(1)
end

os.execute("mkdir -p " .. moddir .. "/textures")


--
-- Compute available tile sizes
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

-- This will give enough combinations (360 is 2 * 2 * 2 * 3 * 3 * 5)
tile_widths = compute_tile_sizes(360)

-- Table width has to be sorted
table.sort(tile_widths)
texture_width = tile_widths[#tile_widths]

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
-- Things start here
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

-- Measures a glyph, returs its height and width in pixels

local function measure(codepoint)
	local char = utf8.char(codepoint)

	local cmd = string.format(
			"convert -font \"%s\" -pointsize %d label:\"%s\" -identify NULL:",
			fontfile, fontsize, escape(char)
		)

	_, _, w, h = string.find(command(cmd), "([0-9]+)x([0-9]+)" )
	return tonumber(w), tonumber(h)
end

-- Read all available codepoints
local cmd, errmsg, status = io.popen("ttx -o - \"" .. fontfile .. "\" 2>/dev/null | grep \"<map code=\" | cut -d \\\" -f 2", 'r')
if cmd == nil then
	print("Could not open font file " .. fontfile .. ":\n" .. errmsg)
	os.exit(status)
end

local codepoints = {}
local codepoint = cmd:read("*line")
while codepoint do
	codepoints[tonumber(codepoint)] = true
	codepoint = cmd:read("*line")
end
cmd:close()

local by_width = {} -- Codepoints by tile width
local tile_widths = {} -- Existing tile width
local glyph_widths = {} -- Exact width of reach glyph
local font_height = 0 -- Max height of all glyphs

local function add_codepoints(from, to)
	for codepoint = from, to do
		if codepoints[codepoint] then
			-- Glyph size
			local w, h = measure(codepoint)
			if h > font_height then font_height = h end
			glyph_widths[codepoint] = w

			-- Tile width
		    local tile_w = tile_width(w)
			if by_width[tile_w] == nil then
				by_width[tile_w] = {}
				table.insert(tile_widths, tile_w)
			end
			table.insert(by_width[tile_w], codepoint)
		end
	end
end

-- Characteristics of [sheet:NxM:x,y
-- M is always the same and depends on font and texture height.
local glyph_xs = {} -- x for each glyph
local glyph_ys = {} -- y for each glyph
local glyph_ns = {} -- n of tiles in sheet for each glyph (=texturewidth / tilewidth)

local texture_height

local function make_final_texture(filename)

	texture_height = font_height
   
	local x = 0 -- cursor x
	local glyph_y = 0

	table.sort(tile_widths)

	-- Compute positions
	for _, tile_width in ipairs(tile_widths) do
		for _, codepoint in ipairs(by_width[tile_width]) do
			local glyph_x = x // tile_width
			x = glyph_x * tile_width
			if x + tile_width > texture_width then -- no space left on current line
				x = 0
				glyph_x = 0
				glyph_y = glyph_y + 1
				texture_height = texture_height + font_height
			end
			glyph_xs[codepoint] = glyph_x
			glyph_ys[codepoint] = glyph_y
			glyph_ns[codepoint] = texture_width // tile_width
			x = x + tile_width
		end
	end

	-- Compose texture
	command(string.format(
		"convert -channel alpha -colorspace gray -size %dx%d xc:transparent %s",
		texture_width, texture_height, filename
	))

	for codepoint, n in pairs(glyph_ns) do
		local w = texture_width // n
		local x = w * glyph_xs[codepoint]
		local y = font_height * glyph_ys[codepoint]
		
		local cmd

		-- Subtexture subcommand
		if codepoint == 0 then
			-- The "unknown" char
  			cmd = string.format("xc:transparent[%dx%d] -background none -colorspace gray -stroke black -fill transparent -strokewidth 1 -draw \"rectangle 0,0 %d,%d\"",
				w, font_height, w - 1, font_height - 1
			)
		else
			-- Other glyhp chars
			cmd = string.format("-channel alpha -background none -colorspace gray -fill black -font \"%s\" -pointsize %d label:\"%s\"",
				fontfile, fontsize, escape(utf8.char(codepoint))
			)
		end
		-- Place subtexure in texture
		cmd = string.format("convert %s \\( %s -repage +%d+%d \\) -flatten %s", filename, cmd, x, y, filename)
		command(cmd)
	end

    command(string.format("convert %s -channel alpha -threshold 50%% %s", filename, filename))

end

print("Compute glyphs properties")

-- TODO: We could get information from ttx:
--   <mtx> gives a width always divisible by 125 for metro font (check if its somehow proportional to what magick gives)
-- 

-- Special char: unknown char
-- We use size of glyph "0" (rounded) but it would be better to get size from ttx
local w = tile_width(measure(0x0030))
glyph_widths[0] = w
by_width[w] = { 0 }
tile_widths = { w }

-- Mandatory chars
add_codepoints(0x0021, 0x007f)

-- TODO: manage Space without texture! + half/quater spaces

-- Optional Unicode pages (see https://en.wikipedia.org/wiki/Unicode) :

-- 00a0-00ff Latin-1 Supplement (full)
add_codepoints(0x00a0, 0x00ff)

-- 0100-017f Latin Extended-A (full)
--add_codepoints(0x0100, 0x017f)

-- 0370-03ff Greek (full)
--add_codepoints(0x0370, 0x03ff)

-- 0400-04ff Cyrilic (full)
--add_codepoints(0x0400, 0x04ff)

-- 2000-206f General Punctuation (Limited to Dashes)
--add_codepoints(0x2010, 0x2015)

-- 2000-206f General Punctuation (Limited to Quotes)
--add_codepoints(0x2018, 0x201F)

-- 20a0-20cf Currency Symbols (Limited to Euro symbol)
--add_codepoints(0x20ac, 0x20ac)

print("Prepare final texture")

make_final_texture(moddir .. "/textures/font_" .. modname .. ".png")

-- Invisible chars : Spaces -- Should be computed from ttx
glyph_widths[0x0020] = glyph_widths[0x0030]

--
-- Write init.lua
--

file = io.open(moddir .. "/init.lua", "w")
file:write(string.format([[
--
-- %s: A '%s' font mod for font_api
--
-- This file was generated by `%s` on %s from file `%s` with size %d.
--

]], modname, fontname, arg[0], os.date("%Y-%m-%d at %H:%M"), fontfile, fontsize
))
file:write(string.format([[
-- luacheck: ignore
font_api.register_font(
	'%s',
	{
		version = 2,
		default = true,
		margintop = 3,
		linespacing = -2,
		texture_height = %d,
		glyphs_height = %d,
		glyphs = {
]],
    fontname, texture_height, font_height)
)
for codepoint, w in pairs(glyph_widths) do
	local x = glyph_xs[codepoint]
	local y = glyph_ys[codepoint]
	local n = glyph_ns[codepoint]
	if x ~= nil and y ~=nil and n ~= nil then
		file:write(string.format("			[%d] = { %d, %d, %d, %d },\n", codepoint, w, n, x, y))
	else
		file:write(string.format("			[%d] = { %d },\n", codepoint, w))
	end
end
file:write([[
		}
	}
);
]])
file:close()


--
-- Write mod.conf
--

local fontlabel = fontname:gsub("^%l", string.upper)

file = io.open(moddir .. "/mod.conf", "w")
file:write(string.format([[
name = font_%s
title = %s Font
description = %s font for font_api
depends = font_api
]], fontname, fontlabel, fontlabel))


