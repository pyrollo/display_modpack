--
-- A font mod generator for font_api
--

-- This files generates only code and textures - should not be translated

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
local moddir = fontname

if os.execute("[ -d " .. moddir .. " ]") then
	print ("Directory " .. moddir .. " already exists!")
--	os.exit(1)
end

os.execute("mkdir -p " .. moddir .. "/textures")

--
-- 
--

local function command(cmd)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	return s
end

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

local bywidth = {} -- Codepoints by glyph width
local widths = {} -- Existing widths
local fontheight = 0 -- Max height of all glyphs

local function add_codepoints(from, to)
	for codepoint = from, to do
		if codepoints[codepoint] then

			local w, h = measure(codepoint)
			if h > fontheight then fontheight = h end

			if bywidth[w] == nil then
				bywidth[w] = {}
				table.insert(widths, w)
			end

			table.insert(bywidth[w], codepoint)

		end
	end
	table.sort(widths)
end

local glyphxs = {} -- x (in grid) for each glyph
local glyphys = {} -- y (in grid) for each glyph
local glyphws = {} -- widths (in pixel) of each glyph

local function make_final_texture(imagewidth, filename)

	local imageheight = fontheight
   
	local x = 0 -- cursor x
	local glyphy = 0

	-- Compute positions
	for _, width in ipairs(widths) do
		for _, codepoint in ipairs(bywidth[width]) do
			local glyphx = math.ceil(x / width)
			x = glyphx * width
			if x + width > imagewidth then -- no space left on current line
				x = 0
				glyphx = 0
				glyphy = glyphy + 1
				imageheight = imageheight + fontheight
			end
			glyphxs[codepoint] = glyphx
			glyphys[codepoint] = glyphy
			glyphws[codepoint] = width
			x = x + width
		end
	end

	-- Compose texture
	command(string.format(
		"convert -channel alpha -colorspace gray -size %dx%d xc:transparent %s",
		imagewidth, imageheight, filename
	))

	for codepoint, w in pairs(glyphws) do
		local x = w * glyphxs[codepoint]
		local y = fontheight * glyphys[codepoint]
		
		local cmd

		-- Subtexture subcommand
		if codepoint == 0 then
			-- The "unknown" char
  			cmd = string.format("-size %dx%d xc:transparent -colorspace gray -stroke black -fill transparent -strokewidth 1 -draw \"rectangle 0,0 %d,%d\"",
				w, fontheight, w-1, fontheight-1
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

    command(string.format("convert %s -threshold 50%% %s", filename, filename))

end

print("Compute glyphs properties")

-- TODO: We could get information from ttx:
--   <mtx> gives a width always divisible by 125 for metro font (check if its somehow proportional to what magick gives)
-- 

-- Special char: unknown char
-- We use size of glyph "0" but it would be better to get size from ttx
local w, _ = measure(0x0030)
bywidth[w] = { 0 }
widths = { w }

-- Mandatory chars
add_codepoints(0x0021, 0x007f)

-- TODO: manage Space without texture! + half/quater spaces

-- Optional Unicode pages (see https://en.wikipedia.org/wiki/Unicode) :

-- 00a0-00ff Latin-1 Supplement (full)
--add_codepoints(0x00a0, 0x00ff)

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

make_final_texture(200, moddir .. "/textures/" .. modname .. "_" .. fontname .. ".png")

-- Invisible chars : Spaces
glyphws[0x0020] = glyphws[0]


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
		default = true,
		margintop = 3,
		linespacing = -2,
		height = %d,
		glyphs = {
]],
    fontname, fontheight)
)
for codepoint, w in pairs(glyphws) do
	x = glyphxs[codepoint]
	y = glyphys[codepoint]
	if x ~= nil and y ~=nil then
		file:write(string.format("			[%d] = { w = %d, x = %d, y = %d },\n", codepoint, w, x, y))
	else
		file:write(string.format("			[%d] = { w = %d },\n", codepoint, w))
	end
end
file:write([[
		}
	}
);
]])
file:close()
