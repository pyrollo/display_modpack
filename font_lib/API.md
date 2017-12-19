# Font Lib API
This document describes Font Lib API. Font Lib creates textures for font display on entities.

## Provided methods
### get\_text\_size
**font\_lib.get\_text\_size(font\_name, text)**

Computes size for a given font and text

**font\_name**: Font name of registered font to use

**text**: Text to be rendered

**Returns**: rendered text width, height

### make\_line\_texture
**font\_lib.make\_line\_texture(font\_name, text, width, x, y)**

Builds texture part for a text line

**font\_name**: Font name of registered font to use

**text**: Text to be rendered

**texturew**: Width of the texture (extra text is not rendered)

**x**: Starting x position in texture

**y**: Vertical position of the line in texture

**Returns**: Texture string

### make\_multiline\_texture
**font\_lib.make\_multiline\_texture(font\_name, text, width, height, maxlines, valign, color)**

Builds texture for a multiline colored text

**font\_name**: Font name of registered font to use

**text**: Text to be rendered

**texturew**: Width of the texture (extra text will be truncated)

**textureh**: Height of the texture

**maxlines**: Maximum number of lines

**valign**: Vertical text align ("top", "bottom" or "center")

**color**: Color of the text

**Returns**: Texture string

### register\_font
**font\_lib.register_font(font\_name, height, widths)**

Registers a new font in font_lib.

**font\_name**: Name of the font to register (this name will be used to address the font later)

**height**: Height of the font in pixels (all font textures should have the same height)

**widths** : An array containing the width of each font texture, indexed by its UTF code

All textures corresponding to the indexes in **widths** array should be present in textures directory with a name matching the pattern :

**font\_<font\_name>_<utf\_code>.png**

<font\_name>: Name of the font as given in the first argument

<utf\_code>: UTF code of the char in 4 hexadecimal digits

To ease that declaration, a shell is provided to build a <font\_name>.lua file from the texture files (see provided tools).

### set\_fallback\_font
**function font\_lib.set\_fallback\_font(font\_name)**

Defines the fallback font to be used instead of given font if not registered.

**font\_name**: Name of the font to be used as fallback font (has to be registered)

## Provided tools

### make_font_lua.sh

Still in early stage of development.

This script analyses textures in textures directory and creates a font\_<font\_name>.lua files with a call to register_font with images information.


