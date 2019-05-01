local config = require("config")
local setting = config.markerValues[settings.startup["note-marker-icon"].value]

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

local function createNoteStorage(name, placeable_by)
	return {
		type = "programmable-speaker",
		name = name,
		icon = "__attach-notes__/graphics/"..setting.sprite,
		icon_size = 42,
		flags = { "player-creation", "placeable-off-grid", "not-deconstructable", "not-repairable", "not-on-map" },
		max_health = 1,
		selectable_in_game = false,
		collision_mask = {},
		collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
		energy_source =
		{
			type = "void",
			usage_priority = "secondary-input",
			input_flow_limit = "0W",
			render_no_network_icon = false,
			render_no_power_icon = false,
		},
		energy_usage_per_tick = "1W",
		sprite = empty,
		audible_distance_modifier = 0,
		maximum_polyphony = 0,
		instruments = {},
		placeable_by = placeable_by,
	}
end

data:extend{
	{
		type = "simple-entity-with-force",
		name = "note-marker",
		flags = {"not-repairable", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map"},
		duration = 9999999,
		spread_duration = 10,
		start_scale = 0.001,
		end_scale = 1,
		color = { r = 1, g = 1, b = 1, a = 1 },
		cyclic = true,
		affected_by_wind = false,
		show_when_smoke_off = true,
		movement_slow_down_factor = 0,
		vertical_speed_slowdown = 0,
		render_layer = "selection-box",
		selectable_in_game = false,
		collision_mask = {},
		picture =
		{
			filename = "__attach-notes__/graphics/"..setting.sprite,
			width = 42,
			height = 42,
			scale = setting.scale,
			frame_count = 1
		}
	},
	{
		type = "flying-text",
		name = "title-flying-text",
		flags = {"not-on-map", "placeable-off-grid"},
		time_to_live = 99999999,
		speed = 0
	},
	createNoteStorage("blueprint-note-storage"), -- for entity attached notes
	{
		type = "item",
		name = "blueprint-note-storage",
		icon = "__attach-notes__/graphics/"..setting.sprite,
		icon_size = 42,
		flags = { "hidden" },
		subgroup = "circuit-network",
		order = "a[signpost]b",	
		place_result = "blueprint-note-storage",
		stack_size = 1
    },
	{
		type = "constant-combinator",
		name = "blueprint-note-interface",
		icon = "__base__/graphics/icons/constant-combinator.png",
		icon_size = 32,
		flags = { "player-creation", "placeable-off-grid", "not-repairable", "not-on-map" },
		max_health = 1,
		selectable_in_game = false,
		collision_mask = {},
		collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
		item_slot_count = 1,
		sprites = { north = empty, east = empty, south = empty, west = empty, },
		activity_led_sprites = { north = empty, east = empty, south = empty, west = empty, },
		activity_led_light_offsets = { {0,0}, {0,0}, {0,0}, {0,0} },
		circuit_wire_connection_points =
		{
			{ shadow = { red = {0, 0}, green = {0, 0} }, wire = { red = {0, 0}, green = {0, 0} } },
			{ shadow = { red = {0, 0}, green = {0, 0} }, wire = { red = {0, 0}, green = {0, 0} } },
			{ shadow = { red = {0, 0}, green = {0, 0} }, wire = { red = {0, 0}, green = {0, 0} } },
			{ shadow = { red = {0, 0}, green = {0, 0} }, wire = { red = {0, 0}, green = {0, 0} } }
		},
		circuit_wire_max_distance = 0
	},
	{
		type = "item",
		name = "blueprint-note-interface",
		icon = "__attach-notes__/graphics/"..setting.sprite,
		icon_size = 42,
		flags = { "hidden" },
		subgroup = "circuit-network",
		order = "a[signpost]c",	
		place_result = "blueprint-note-interface",
		stack_size = 1
    },
}