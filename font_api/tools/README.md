# Mod maker for FontAPI

This tool makes font mods out of a true type font file.

```
lua <params.lua> <font_file>
```

## Installation

This tool needs some aditional programs:
* `lua` to be able to launch it from command line
* `imagemagick` to process images and build texture
* `fonttools` and `xmlstarlet` to analyse true type font

On Debian like distros, these could be installing issuing:

```shell
apt install lua5.4 imagemagick fonttools xmlstarlet
```
