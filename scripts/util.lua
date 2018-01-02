local util = {}
local tables = require("tables")

function util.doEvery(tick, func, args)
	if (game.tick % tick) == 0 then func(args) end
end

function util.mod(name)
	return game.active_mods[name]
end

function util.trim(str)
  return str and (str:gsub("^%s*(.-)%s*$", "%1")) or ""
end

function util.fullTrim(str) -- trim and also remove multiple white spaces
  return (util.trim(str):gsub("[ \t\r\n]*[\r\n][ \t\r\n]*", "\r\n"):gsub("[ \t]+", " "))
end

local quotepattern = '(['..("%^$().[]*+-?"):gsub("(.)", "%%%1")..'])'
function util.escape(str) -- escape string for use with regex
    return str:gsub(quotepattern, "%%%1")
end

function util.offsetPosition(pos, offX, offY)
	return { x = pos.x + offX, y = pos.y + offY }
end

function util.getSurroundingArea(pos, radius)
	return { left_top = { x = pos.x - radius, y = pos.y - radius },
			 right_bottom = { x = pos.x + radius, y = pos.y + radius } }
end

function util.calcArea(area)
	return math.abs((area.right_bottom.x - area.left_top.x) * (area.right_bottom.y - area.left_top.y))
end

function util.isValid(object)
	return type(object) == "table" and object.valid
end

function util.destroyIfValid(object)
	if util.isValid(object) then object.destroy() end
end

function util.isValidStack(stack)
	return util.isValid(stack) and stack.valid_for_read
end

function util.isValidPlayer(player) -- valid, connected and alive player
	return util.isValid(player) and player.connected and player.controller_type ~= defines.controllers.ghost
end

function util.isValidArea(area)
	return area and area.left_top and area.right_bottom and util.calcArea(area) > 0
end

function util.fixArea(area) -- fix an area for use in surface.find_entities_filtered, returns key,value pair
	if util.isValidArea(area) then
		return "area", area
	else
		return "position", area.left_top
	end
end

function util.iterateInvs(player, func) -- iterate over all ItemStacks of this player (in all inventories)
	local stack = player.cursor_stack
	if util.isValidStack(stack) and func(stack) then return true end

	for _,invIndex in pairs(defines.inventory) do
		local inv = player.get_inventory(invIndex)
		if util.isValid(inv) and not inv.is_empty() then
			
			for i = 1, #inv do
				stack = inv[i]
				if util.isValidStack(stack) and func(stack) then return true end
			end
		end
	end
	
	return false
end

function util.iconHasItem(icon)
	return icon and icon.name and util.isValid(game.item_prototypes[icon.name])
end

function util.supportsNotes(entity)
	local name = entity.type == "entity-ghost" and entity.ghost_name or entity.name
	local type = entity.type == "entity-ghost" and entity.ghost_type or entity.type
	
	if name == "blueprint-note-storage" then return false end
	return tables.offerAttachNote[type] or tables.alwaysAttachNote[type] or tables.alwaysAttachNote[name]
end

local function isTemporaryBp(player, stack) -- TODO: fix
	return util.mod("PickerExtended") and stack.label and (
				stack.label:find("Belt Brush") or
				stack.label:find("Pipette Blueprint"))
end

function util.supportsBpNote(stack) 
	return util.isValidStack(stack) and stack.is_blueprint and stack.is_blueprint_setup() and not isTemporaryBp(player, stack) -- or stack.is_blueprint_book
end	

function util.getColorOrDefault(name, settings, note, replacements)
	local color = "white" --"black"
	
	if note and note[name.."Color"] then
		local saved = note[name.."Color"]
		if type(saved) == "table" then return saved end -- if rgb value is saved return it directly
		color = tables.colors[saved]
	elseif settings then
		if name == "label" then name = "title" end
		color = settings["default-"..name.."-color"].value
	end
	
	return tables.colorFromName[(replacements and replacements[color]) or color]
end

function util.shallowCopy(original) -- Creates a shallow copy of a table
    copy = {}
    for key,value in pairs(original) do copy[key] = value  end
    return copy
end

function util.countTable(tbl)
	local count = 0
	for _,__ in pairs(tbl) do count = count + 1 end
	return count
end

function util.isEmpty(tbl)
	return next(tbl) == nil
end

function util.findInTable(tbl, func)
	for key,value in pairs(tbl) do
		if func(value, key) then return value, key end
	end
end

function util.concat(arrays)
	local result, lastIndex = {}, 0
	for _,arr in ipairs(arrays) do
		for index,value in ipairs(arr) do
			result[lastIndex + index] = value
		end
		lastIndex = lastIndex + #arr
	end
	return result
end

function util.localize(array, section)
	section = section..'.'
	local localized = {}
	for i,val in ipairs(array) do
		localized[i] = {section..val}
	end
	return localized
end

function util.epairs(tbl) -- iterator for tables with entity based indices
	local tblId = rawget(tbl, "id")
	local tblPos = rawget(tbl, "pos")
	local idIterator, posIterator
	local currentIterator
	
	if tblPos then
		posIterator = pairs(tblPos)
		currentIterator = posIterator
	end
	if tblId then
		idIterator = pairs(tblId)
		currentIterator = idIterator
	end
	
	return function ()
		local index, value
		if currentIterator then index, value = currentIterator() end
		if not index and currentIterator == idIterator then
			currentIterator = posIterator
			if currentIterator then index, value = currentIterator() end
		end
		return value
	end
end

return util