local config = require("config")

local empty = {
	filename = "__core__/graphics/empty.png",
	priority = "extra-high",
	line_length = 1,
	width = 1,
	height = 1,
	frame_count = 1,
	direction_count = 1,
	animation_speed = 1,
}

local sounds = require("__base__.prototypes.entity.sounds")

data:extend{
	{
		type = "technology",
		name = "signpost",
		icon = "__attach-notes__/graphics/signpost-icon.png",
		icon_size = 32,
        icon_mipmaps = 1,
		effects =
		{
		  {
			type = "unlock-recipe",
			recipe = "signpost"
		  }
		},
		unit =
		{
		  count = 20,
		  ingredients = {{"automation-science-pack", 1}},
		  time = 10
		},
		order = "a-k-a"
	},
	{
		type = "recipe",
		name = "signpost",
		enabled = false,
		ingredients =
		{
		  { "iron-plate", 2 },
		  { "iron-stick", 1 }
		},
		result = "signpost",
		energy_required = 2
    },
	{
		type = "item",
		name = "signpost",
		icon = "__attach-notes__/graphics/signpost-icon.png",
		icon_size = 32,
        icon_mipmaps = 1,
		subgroup = "circuit-network",
		order = "a[signpost]",	
		place_result = "signpost",
		stack_size = 50
    },
	{
		type = "storage-tank", -- storage tank can have an empty ingame gui which can be opened (even without circuit conditions)
		name = "signpost",
		se_allow_in_space = true,
		render_layer = "object",
		icon = "__attach-notes__/graphics/signpost-icon.png",
		icon_size = 32,
        icon_mipmaps = 1,
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.5, result = "signpost" },
		max_health = 200,
		resistances =
		{
		  {
			type = "fire",
			percent = 80
		  },
		  {
			type = "impact",
			percent = 30
		  }
		},
		corpse = "small-remnants",
		collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		vehicle_impact_sound = sounds.generic_impact,
		fluid_box =
		{
		  base_area = 0.0000001,
		  pipe_connections = {}
		},
		window_bounding_box = {{0, 0}, {0, 0}},
		flow_length_in_ticks = 1,
		pictures =
		{
			picture =
			{
				sheet =
				{
					filename = "__attach-notes__/graphics/signpost.png",
					priority = "extra-high",
					frames = 1,
					width = 64,
					height = 32,
					shift = {0.56, -0.125},
					scale = 1.2
				}
			},
			fluid_background = empty,
			window_background = empty,
			flow_sprite = empty,
			gas_flow = empty
		}
	},
	{
		type = "container",
		name = "signpost-display",
		icon = "__base__/graphics/icons/iron-chest.png",
		icon_size = 32,
        icon_mipmaps = 1,
		flags = { "placeable-off-grid", "not-repairable", "not-blueprintable", "not-deconstructable", "not-on-map" },
		collision_mask = {},
		max_health = 1,
		selectable_in_game = false,
		inventory_size = 1,
		picture = empty,
	},
}