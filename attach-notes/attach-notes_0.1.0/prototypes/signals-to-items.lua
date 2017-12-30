local util = require("scripts.util")

local function convertToItem(signal)
	local item = util.shallowCopy(signal)
	item.type = "item"
	item.flags = { "hidden" }
	item.stack_size = 1
	return item
end

for _,signal in pairs(data.raw["virtual-signal"]) do
	if not signal.special_signal then data:extend{ convertToItem(signal) } end
end

for _,fluid in pairs(data.raw["fluid"]) do
	data:extend{ convertToItem(fluid) }
end