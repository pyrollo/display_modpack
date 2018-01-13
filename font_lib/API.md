# Font Lib API
This document describes Font Lib API. Font Lib creates textures for font display on entities.

## Settings
### default_font
Name of the font to be used when no font is given. The font should be registered.
If no default\_font given or if default\_font given but not registered, the first registered font will be used as default.

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
**font\_lib.make\_multiline\_texture(font\_name, text, width, height, maxlines, halign, valign, color)**

Builds texture for a multiline colored text

**font\_name**: Font name of registered font to use
**text**: Text to be rendered
**texturew**: Width of the texture (extra text will be truncated)
**textureh**: Height of the texture
**maxlines**: Maximum number of lines
**halign**: Horizontal text align ("left", "right" or "center") (optional)
**valign**: Vertical text align ("top", "bottom" or "center") (optional)
**color**: Color of the text (optional)
**Returns**: Texture string

### register\_font
**font\_lib.register_font(font\_name, height, widths)**

Registers a new font in font_lib.

**font\_name**: Name of the font to register (this name will be used to address the font later)
If registering different sizes of the same font, add size in the font name (e.g. times\_10,  times\_12...).
**height**: Font height in pixels (all font textures should have the same height)
**widths** : Array of character widths in pixels, indexed by UTF codepoints

Font must have a char 0 which will be used to display any unknown char.

All textures corresponding to the indexes in **widths** array should be present in textures directory with a name matching the pattern :

**font\_<font\_name>_<utf\_code>.png**

**<font\_name>**: Name of the font as given in the first argument
**<utf\_code>**: UTF code of the char in 4 hexadecimal digits

To ease that declaration, a shell is provided to build a <font\_name>.lua file from the texture files (see provided tools).

## Provided tools

Still in early stage of development, these tools are helpers to create font mods.

### make_font_texture.sh

This scripts takes a .ttf file as input and create one .png file per char, that can be used as font texture. Launch it from your future font mod directory. 

__Advice__

This script works much better with pixels font, providing the correct height. There is no antialiasing at all, vector fonts and bad heights gives very ugly results.

__Syntax__

**make\_font\_texture.sh <fontfile> <fontname> <fontsize>**

**<fontfile>**: A TTF font file to use to create textures.
**<fontname>**: The font name to be used in font_lib (should be simple, with no spaces).
**<fontsize>**: Font height to be rendered.

### make_font_lua.sh

This script analyses textures in textures directory and creates a font\_<font\_name>.lua files with a call to register_font with images information. Launch it from your future font mod directory. 

Once the font\_<font\_name>.lua created, it can be included by a init.lua file or directly renamed to init.lua if you are creating a simple font mod.

__Syntax__

**make\_font_lua.sh <fontname>**

**<fontname>**: The font name to be used in font_lib (same as given to make\_font\_texture.sh)

### An exemple generating a font mod

    mkdir font_myfont
    cd font_myfont
    /<path_to_font_lib>/tools/make_font_texture.sh myfont.ttf myfont 12
    /<path_to_font_lib>/tools/make_font_lua.sh myfont
    mv font_myfont.lua init.lua





