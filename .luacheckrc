unused_args = false

ignore = {
    "431", -- Shadowing an upvalue
	"432", -- Shadowing an upvalue argument
    "631", -- Line is too long
}

read_globals = {
    "minetest",
    "string",
    "table",
    "vector",
    "default"
}

globals = {
    "boards",
    "display_api",
    "font_api",
    "ontime_clocks",
    "signs",
    "signs_api",
    "signs_road",
    "steles"
}