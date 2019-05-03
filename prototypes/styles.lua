-- GUI styles --

local config = require("config")

local empty = {
		filename = "__core__/graphics/empty.png",
	position = {0, 0},
	size = {1, 1},
	scale = 0,
	border = 0,
	}

data.raw["gui-style"].default["entity_note_style"] =
{
	type = "textbox_style",
	parent = "textbox",
	width = 265,
	height = 330,
	left_padding = 0,
	right_padding = 5,

	default_background =
	{
		base = {position = {248, 0}, corner_size = 8, opacity = 0.7},
		shadow = textbox_dirt
	},
	disabled_font_color = util.premul_color {1, 1, 1, 0.5},
	active_background =
	{
		base = {position = {265, 0}, corner_size = 8, opacity = 0.7},
		shadow = textbox_dirt
	},
	disabled_background =
	{
		base = {position = {282, 0}, corner_size = 8, opacity = 0.7},
		shadow = textbox_dirt
	},
	selection_background_color= {241, 190, 100},
	rich_text_setting = "enabled"
}

data.raw["gui-style"].default["entity_title_style"] =
{
	type = "textbox_style",
	parent = "textbox",
	width = 237,
	font = "default-large-bold",

	default_background =
	{
		base = {position = {248, 0}, corner_size = 8, opacity = 0.7},
		shadow = textbox_dirt
	},
	disabled_font_color = util.premul_color {1, 1, 1, 0.5},
	active_background =
	{
		base = {position = {265, 0}, corner_size = 8, opacity = 0.7},
		shadow = textbox_dirt
	},
	disabled_background =
	{
		base = {position = {282, 0}, corner_size = 8, opacity = 0.7},
		shadow = textbox_dirt
	},
	selection_background_color= {241, 190, 100},
	rich_text_setting = "enabled"
}

data.raw["gui-style"].default["font_settings_style"] =
{
	type = "dropdown_style",
	parent = "dropdown",
	width = 148,
}

data.raw["gui-style"].default["color_picker_button_style"] =
{
	type = "button_style",
	parent = "button",
	font = "default",
	left_padding = 0,
	right_padding = 0,
	top_padding = -1,
	bottom_padding = 0,
	minimal_width = 0,
	minimal_height = 0,
}

data.raw["gui-style"].default["color_button_style"] =
{
	type = "button_style",
	parent = "button",
	font = "default",
	left_padding = -1,
	right_padding = -1,
	top_padding = -1,
	bottom_padding = 0,
	minimal_width = 0,
	minimal_height = 0,
}

data.raw["gui-style"].default["color_picker_frame_style"] =
{
	type = "frame_style",
	parent = "frame",
	
	width = 265,
	
	left_padding = -1,
	right_padding = 0,
	top_padding = 0,
	bottom_padding = 0,
}

data.raw["gui-style"].default["color_picker_table_style"] =
{
	type = "table_style",
	parent = "table",
	
	width = 265,
	
	left_padding = 4,
	right_padding = 0,
	top_padding = 2,
	bottom_padding = 2,
	
	horizontal_spacing = 6,
	vertical_spacing = 0,
	cell_spacing = 0,
}

data.raw["gui-style"].default["icon_style"] =
{
	type = "button_style",
	parent = "button",
	left_padding = 0,
	right_padding = 0,
	top_padding = 0,
	bottom_padding = 0,
	
	minimal_width = 32,
	minimal_height = 32,

	default_graphical_set = empty,
	hovered_graphical_set = empty,
	clicked_graphical_set = empty
}

-- GUI button icon sprites --

local function addButtonStyle(name, x, y)
	
	data.raw["gui-style"].default["attach-notes-"..name.."-button"] =
    {
        type = "button_style",
        parent = "button",
        width = 33,
		height = 33,
        top_padding = 6,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        default_graphical_set =
        {
                filename = "__attach-notes__/graphics/gui.png",
			position = {x, y},
			size = {32, 32},	        
        },
        hovered_graphical_set =
        {
                filename = "__attach-notes__/graphics/gui.png",
			position = {x + 32, y},
			size = {32, 32},	        
        },
        clicked_graphical_set =
        {
                filename = "__attach-notes__/graphics/gui.png",
			position = {x + 64, y},
			size = {32, 32},    
        }
	}
end

addButtonStyle("add", 64, 0)
addButtonStyle("delete", 64, 32)
addButtonStyle("edit", 160, 0)
addButtonStyle("view", 160, 32)