# Font Lib API
This document describes Font Lib API. Font Lib creates textures for font display on entities.

## Provided methods
### get\_line\_width
**font\_lib.get\_line\_width(text)**

Computes line width for a given font height and text
**text**: Text to be rendered

**Returns**: rendered text width

### make\_line\_texture
**font\_lib.make\_line\_texture(text, texturew, x, y)**

Builds texture part for a text line

**text**: Text to be rendered

**texturew**: Width of the texture (extra text is not rendered)

**x**: Starting x position in texture

**y**: Vertical position of the line in texture

**Returns**: Texture string

### make\_multiline\_texture
**font\_lib.make\_multiline\_texture(text, texturew, textureh, maxlines, valign, color)**

Builds texture for a multiline colored text

**text**: Text to be rendered

**texturew**: Width of the texture (extra text will be truncated)

**textureh**: Height of the texture

**maxlines**: Maximum number of lines

**valign**: Vertical text align ("top" or "center")

**color**: Color of the text

**Returns**: Texture string


