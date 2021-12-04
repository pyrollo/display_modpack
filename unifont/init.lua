local widths = {}
for i = 0,65535 do
	widths[i] = 16
end
for i = 32,126 do
	widths[i] = 8
end

local function get_glyph(codepoint)
	if codepoint == 0 or codepoint > 0xffff then
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
		linespacing = -1,
		height = 16,
		widths = widths,
		get_glyph = get_glyph,
	}
)
