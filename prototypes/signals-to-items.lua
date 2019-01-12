local util = require("scripts.util")

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

for _,signal in pairs(data.raw["virtual-signal"]) do
	if not signal.special_signal and not data.raw.item[signal.name] then data:extend{ convertToItem(signal, "virtual-signal") } end
end

for _,fluid in pairs(data.raw["fluid"]) do
	if not data.raw.item[fluid.name] then data:extend{ convertToItem(fluid, "fluid") } end
end