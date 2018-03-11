local tables = require("tables")

data:extend{
	{
		type = "bool-setting",
		name = "show-note-on-hover",
		setting_type = "runtime-per-user",
		order = "a",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "hide-note-by-default",
		setting_type = "runtime-per-user",
		order = "aa",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "copy-paste-attached-notes",
		setting_type = "runtime-per-user",
		order = "ab",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "show-marker-by-default",
		setting_type = "runtime-per-user",
		order = "ac",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "show-flyingText-by-default",
		setting_type = "runtime-per-user",
		order = "ad",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "show-mapTag-by-default",
		setting_type = "runtime-per-user",
		order = "ae",
		default_value = false
	},
	{
		type = "string-setting",
		name = "default-font",
		setting_type = "runtime-per-user",
		order = "ba",
		default_value = tables.fonts[5],
		allowed_values = tables.fonts
	},
	{
		type = "string-setting",
		name = "default-text-color",
		setting_type = "runtime-per-user",
		order = "bb",
		default_value = tables.colors[2],
		allowed_values = tables.colors
	},
	{
		type = "string-setting",
		name = "default-title-color",
		setting_type = "runtime-per-user",
		order = "bc",
		default_value = tables.colors[2],
		allowed_values = tables.colors
	},
	{
		type = "string-setting",
		name = "note-marker-icon",
		setting_type = "startup",
		order = "a",
		default_value = tables.markers[4],
		allowed_values = tables.markers
	}
}