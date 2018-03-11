-- GUI styles --

local empty = {
	type = "monolith",
	monolith_border = 0,
	monolith_image =
	{
		filename = "__core__/graphics/empty.png",
		priority = "extra-high",
		width = 0,
		height = 0,
		x = 0,
		y = 0
	}
}

local function generateTextBoxStyles(opacity)
	data.raw["gui-style"].default["entity_note_style_op"..opacity..'%'] =
	{
		type = "textbox_style",
		parent = "textbox",
		width = 265,
		height = 330,
		graphical_set =
		{
			type = "composition",
			filename = "__core__/graphics/gui.png",
			priority = "extra-high-no-scale",
			corner_size = {3, 3},
			position = {16, 0},
			opacity = opacity / 100
		},
	}
	
	data.raw["gui-style"].default["entity_title_style_op"..opacity..'%'] =
	{
		type = "textfield_style",
		parent = "textfield",
		width = 237,
		font = "default-large-bold",
		graphical_set =
		{
			type = "composition",
			filename = "__core__/graphics/gui.png",
			priority = "extra-high-no-scale",
			corner_size = {3, 3},
			position = {16, 0},
			opacity = opacity / 100
		},
	}
end

for opacity = 10, 100, 10 do
	generateTextBoxStyles(opacity)
end

data:extend{
	{
		type = "font",
		name = "color-picker-button",
		from = "default-bold",
		size = 14
	},
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
	left_padding = 1,
	right_padding = 1,
	top_padding = 2,
	bottom_padding = 0,
}

data.raw["gui-style"].default["color_button_style"] =
{
	type = "button_style",
	parent = "button",
	left_padding = 1,
	right_padding = 1,
	top_padding = 2,
	bottom_padding = 0,
}

data.raw["gui-style"].default["color_picker_frame_style"] =
{
	type = "frame_style",
	parent = "frame",
	
	width = 265,
	
	left_padding = 0,
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
            type = "monolith",
            monolith_image =
            {
                filename = "__attach-notes__/graphics/gui.png",
                priority = "extra-high-no-scale",
                width = 32,
                height = 32,
                x = x,
				y = y,
            }
        },
        hovered_graphical_set =
        {
            type = "monolith",
            monolith_image =
            {
                filename = "__attach-notes__/graphics/gui.png",
                priority = "extra-high-no-scale",
                width = 32,
                height = 32,
                x = x + 32,
				y = y,
            }
        },
        clicked_graphical_set =
        {
            type = "monolith",
            monolith_image =
            {
                filename = "__attach-notes__/graphics/gui.png",
                width = 32,
                height = 32,
                x = x + 64,
				y = y,
            }
        }
	}
end

addButtonStyle("add", 64)
addButtonStyle("delete", 64, 32)
addButtonStyle("edit", 160)
addButtonStyle("view", 160, 32)