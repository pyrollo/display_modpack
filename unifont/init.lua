local widths = {}

for i = 0,0xd7ff do
	widths[i] = 16
end
for i = 0xe000,0xfffd do
	widths[i] = 16
end

local halfwidth = dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/halfwidth.lua")
for i, codepoint in ipairs(halfwidth) do
	widths[codepoint] = 8
end

local function get_glyph(codepoint)
	if codepoint == 0 or codepoint > 0xffff or widths[codepoint] == nil then
		codepoint = 0xfffd
	end
	local x = codepoint % 256
	local y = math.floor(codepoint / 256)
	return string.format("font_unifont_sheet.png^[sheet:256x256:%d,%d", x, y)
end

font_api.register_font(
	"unifont",
	{
		default = true,
		margintop = 2,
		marginbottom = 2,
		linespacing = -3,
		height = 16,
		widths = widths,
		getglyph = get_glyph,
	}
)
