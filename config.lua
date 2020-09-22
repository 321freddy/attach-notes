local config = {}

config.fonts = {"default", "default-semibold", "default-bold",
			    "default-large", "default-large-semibold", "default-large-bold",
				"default-small", "default-small-semibold", "default-small-bold"}

config.colors = {"black", "white", "red", "orange", "yellow", "lime", "green", "cyan", "blue", "pink"}				
				
config.colorFromName = {
	black  = { r = 0, g = 0, b = 0 },
	white  = { r = 1, g = 1, b = 1 },
	red    = { r = 0.94510, g = 0.14118, b = 0.14118 },
	orange = { r = 0.86667, g = 0.58039, b = 0.00784 },
	green  = { r = 0.09804, g = 0.70980, b = 0.29020 },
	lime   = { r = 0.57647, g = 0.97647, b = 0.27059 },
	blue   = { r = 0.30980, g = 0.57647, b = 0.97647 },
	yellow = { r = 0.93725, g = 0.92549, b = 0.09020 },
	pink   = { r = 0.94510, g = 0.27059, b = 0.88824 },
	cyan   = { r = 0.34902, g = 0.90588, b = 0.97647 }
}

config.markers = {"Question mark", "Magnifying glass", "Small question mark", "Small magnifying glass"}

config.markerValues = {
	["Question mark"]          = { sprite = "note-marker-question-mark.png", scale = 0.5 },
	["Magnifying glass"]       = { sprite = "note-marker-magnifying-glass.png", scale = 0.5 },
	["Small question mark"]    = { sprite = "note-marker-question-mark.png", scale = 0.3 },
	["Small magnifying glass"] = { sprite = "note-marker-magnifying-glass.png", scale = 0.3 }
}

config.disableMarker = {
	["locomotive"]     = true,
	["fluid-wagon"]    = true,
	["cargo-wagon"]    = true,
	["car"]            = true,
	["spider-vehicle"] = true,
	["signpost"]       = true,
}

config.disableTitle = {
	["locomotive"]     = true,
	["fluid-wagon"]    = true,
	["cargo-wagon"]    = true,
	["car"]            = true,
	["spider-vehicle"] = true,
}

config.alwaysAttachNote = {
	--["decider-combinator"]    = true,
	--["arithmetic-combinator"] = true,
	--["constant-combinator"]   = true,
	--["programmable-speaker"]  = true,
	["signpost"]                = true,
}

config.offerAttachNote = {
	["assembling-machine"]    = true,
	["furnace"]               = true,
	["inserter"]              = true,
	["transport-belt"]        = true,
	["rocket-silo"]           = true,
	["beacon"]                = true,
	["train-stop"]            = true,
	["rail-signal"]           = true,
	["lab"]                   = true,
	["roboport"]              = true,
	["container"]             = true,
	["logistic-container"]    = true,
	["pump"]                  = true,
	["market"]                = true,
	["accumulator"]           = true,
	["power-switch"]          = true,
	["reactor"]               = true,
	["boiler"]                = true,
	["loader"]                = true,
	["locomotive"]            = true,
	["fluid-wagon"]           = true,
	["cargo-wagon"]           = true,
	["wall"]                  = true,
	["offshore-pump"]         = true,
	["lamp"]                  = true,
	["mining-drill"]          = true,
	["storage-tank"]          = true,
	["car"]                   = true,
	["spider-vehicle"]        = true,
	["ammo-turret"]           = true,
	["artillery-turret"]      = true,
	["decider-combinator"]    = true,
	["arithmetic-combinator"] = true,
	["constant-combinator"]   = true,
	["programmable-speaker"]  = true,
}

config.markerOffsets = {
	["rail-signal"]   = { x = 0.5, y = 0.5 },
	["oil-refinery"]  = { x = 1.5, y = 2.25 },
	["offshore-pump"] = { x = 0.35, y = 0.25 }
}

config.titleOffsets = {
	["signpost"]      = { x = 0, y = 0.2 },
	["rocket-silo"]   = { x = 0, y = -3 },
	["offshore-pump"] = { x = 0, y = -0.75 }
}

return config