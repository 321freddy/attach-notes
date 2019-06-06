local util = require("scripts.util")
local raw = data.raw

local function convertToItem(signal, type)
	local item = util.deepCopy(signal)
	item.type = "item"
	item.localised_name = {type.."-name."..item.name}
	item.flags = { "hidden", "hide-from-bonus-gui", "hide-from-fuel-tooltip" }
	item.stack_size = 1
	item.fuel_value = nil
	item.fuel_category = nil
	item.fuel_acceleration_multiplier = nil
	item.fuel_top_speed_multiplier = nil
	item.fuel_emissions_multiplier = nil
	item.fuel_glow_color = nil
	return item
end

local function itemExists(name)
	return raw.item[name] or 
		   raw.ammo[name] or 
		   raw.armor[name] or 
		   raw.capsule[name] or 
		   raw.gun[name] or 
		   raw.module[name] or 
		   raw.tool[name] or 
		   raw.blueprint[name] or 
		   raw["repair-tool"][name] or 
		   raw["rail-planner"][name] or 
		   raw["item-with-entity-data"][name] or 
		   raw["item-with-tags"][name] or 
		   raw["item-with-label"][name] or 
		   raw["item-with-inventory"][name] or 
		   raw["copy-paste-tool"][name] or 
		   raw["upgrade-item"][name] or 
		   raw["deconstruction-item"][name] or 
		   raw["blueprint-book"][name] or 
		   raw["selection-tool"][name] or 
		   (raw["mining-tool"] and raw["mining-tool"][name])
end

for _,signal in pairs(raw["virtual-signal"]) do
	if not signal.special_signal and not itemExists(signal.name) then 
		data:extend{ convertToItem(signal, "virtual-signal") }
	end
end

for _,fluid in pairs(raw["fluid"]) do
	if not itemExists(fluid.name) then 
		data:extend{ convertToItem(fluid, "fluid") } 
	end
end