
-- This is an example parameter file for make_font.lua
-- Copy this file as params.lua.
-- Replace values between brakets <> to your choices.
-- Launch make_font.lua params.lua

params = {
	-- Resulting mod name (required)
	-- As this name will be use as texture prefix and so repeated many times,
	-- please avoid long names but keep explicit anyway.
	mod_name = "fonts_extra",

    -- If only one font, have font in title, like "xxx font"
	mod_title = "Extra fonts",

    -- A good description would be "... fonts for font_api"
	mod_description = "Extra fonts for font_api: botic",

	-- List of fons to include to the mod.
	fonts = {
		{
			-- Registered font name (required)
			-- As this name will be use as texture prefix and so repeated many times,
			-- avoid long names. A good name would be a single world all lowercase.
			name = "botic",

			-- Registered font label (optional, default capitalized name)
			-- This is the display name for this font. No need to be concise.
			label = "Botic",

			-- True type font file to get glyphs from (required)
			file = "sources/pixeldroidBoticRegular.otf",

			-- Author(s) of the original font (required)
			author = "pixeldroid",
			
			-- License of the original font (required)
			-- Join license text, as a text file, to your mod.
			license = "Open Font License",

			-- Render pointsize (integer, required)
			-- Try to find a proper value for a good rendering
			pointsize = 16,

			-- Shoud chars be trimmed? (boolean, required)
			-- Set it to true to reduce texture size
			-- and increase `char_spacing` accordingly.
			-- If results are weird, you may try to set it to false.
			trim = true,

			-- Margin added on top of text textures with this font (integer, optional, default 0)
			margin_top = 0,

			-- Space between consecutive lines (integer, optional, default 0)
			-- Space may be negative to make lines closer.
			line_spacing = 0,

			-- Space between consecutive chars (integer, optional, default 0)
			char_spacing = 2,

			-- Extra codepoints to include to font mod (optional, default none)
			-- Codepoints from 0x0020 to 0x007f (ASCII) are always included.
			-- Codepoint 0x0020 is always considered as a space.
            -- Codepoints not existing in font file will be ignored.
			-- Refer to https://en.wikipedia.org/wiki/Unicode
			codepoints = {
				-- 00a0-00ff Latin-1 Supplement (full except nbsp)
				{ from = 0x00a1, to = 0x00ff },

				-- 20a0-20cf Currency Symbols (Limited to Euro symbol)
				{ from = 0x20ac, to = 0x20ac },
			},
		}, {
			-- Registered font name (required)
			-- As this name will be use as texture prefix and so repeated many times,
			-- avoid long names. A good name would be a single world all lowercase.
			name = "oldwizard",

			-- Registered font label (optional, default capitalized name)
			-- This is the display name for this font. No need to be concise.
			label = "Old Wizard",

			-- True type font file to get glyphs from (required)
			file = "sources/OldWizard.ttf",

			-- Author(s) of the original font (required)
			author = "Angel",
			
			-- License of the original font (required)
			-- Join license text, as a text file, to your mod.
			license = "Public Domain",

			-- URL of the original font (optional)
			-- This is an optional field but it is recommended to put an URL
			-- if it exists.
			url = "http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=168",

			-- Render pointsize (integer, required)
			-- Try to find a proper value for a good rendering
			pointsize = 16,

			-- Shoud chars be trimmed? (boolean, required)
			-- Set it to true to reduce texture size
			-- and increase `char_spacing` accordingly.
			-- If results are weird, you may try to set it to false.
			trim = true,

			-- Margin added on top of text textures with this font (integer, optional, default 0)
			margin_top = 0,

			-- Space between consecutive lines (integer, optional, default 0)
			-- Space may be negative to make lines closer.
			line_spacing = 0,

			-- Space between consecutive chars (integer, optional, default 0)
			char_spacing = 2,

			-- Extra codepoints to include to font mod (optional, default none)
			-- Codepoints from 0x0020 to 0x007f (ASCII) are always included.
			-- Codepoint 0x0020 is always considered as a space.
            -- Codepoints not existing in font file will be ignored.
			-- Refer to https://en.wikipedia.org/wiki/Unicode
			codepoints = {
				-- 00a0-00ff Latin-1 Supplement (full except nbsp)
				{ from = 0x00a1, to = 0x00ff },

				-- 20a0-20cf Currency Symbols (Limited to Euro symbol)
				{ from = 0x20ac, to = 0x20ac },
			},
		},
	}
}
