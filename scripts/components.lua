-- Note components

local components = {}
local util = scripts.util
local config = require("config")

local function getMarkerOffset(entity) -- generates marker offsets with some crazy math
	local pos, boundingBox, selectionBox = entity.position, entity.bounding_box, entity.prototype.selection_box
	local width = boundingBox.right_bottom.x - boundingBox.left_top.x
	local offX, offY = boundingBox.right_bottom.x - width / 3.35 - pos.x
	
	if boundingBox.right_bottom.x - pos.x > boundingBox.right_bottom.y - pos.y then
		offY = math.min(selectionBox.right_bottom.x, selectionBox.right_bottom.y)
	else
		offY = math.max(selectionBox.right_bottom.x, selectionBox.right_bottom.y)
	end
	
	return { x = offX, y = offY - 0.25 }
end

local function getFlyingTextOffset(entity)
	local offset = { x = 0, y = 0 }
	local boundingBox = entity.bounding_box
	
	if boundingBox.right_bottom.y - boundingBox.left_top.y <= 1.1 then -- avoid marker overlap
		offset.y = getMarkerOffset(entity).y - 0.7
	end
	
	return offset
end

components.marker = {
	create = function (entity)
		local pos = entity.position
		local offset = config.markerOffsets[entity.name] or getMarkerOffset(entity)
		
		return entity.surface.create_entity{
			name = "note-marker",
			position = { x = pos.x + offset.x, y = pos.y + offset.y },
			force = entity.force
		}
	end,
	isDisabledForEntity = function (entity)
		return config.disableMarker[entity.type] or config.disableMarker[entity.name]
	end,
	showByDefault = function (note)
		return not note.text
	end
}

components.mapTag = {
	create = function (entity, note)
		local tag = entity.force.add_chart_tag(entity.surface, {
			icon = note.icon,
			position = entity.position,
			text = note.title and #note.title > 0 and note.title or " ",
			target = entity
		})
		
		tag.last_user = entity.last_user
		return tag
	end,
	update = function (entity, note)
		if util.isValid(note.mapTag) then
			note.mapTag.text = note.title or " "
		
			local icon = note.icon
			if icon then
				note.mapTag.icon = icon
			else
				note.mapTag.destroy()
				note.mapTag = components.mapTag.create(entity, note)
			end
		end
	end,
	isDisabledForEntity = function (entity)
		return entity.name ~= "signpost"
	end,
	showByDefault = function (note)
		return not (note.icon or note.title)
	end
}

components.flyingText = {
	create = function (entity, note, player)
		local pos = entity.position
		local offset = config.titleOffsets[entity.name] or getFlyingTextOffset(entity)
		local title = note.title and util.fullTrim(note.title) or " "
		if #title == 0 then title = " " end
		
		local created = entity.surface.create_entity{
			name = "title-flying-text",
			position = { x = pos.x + offset.x, y = pos.y + offset.y },
			force = entity.force,
			text = title,
			color = util.getColorOrDefault("title", player and player.mod_settings, note) --{black = "white"}
		}
		
		created.active = false
		return created
	end,
	update = function (entity, note, player)
		if util.isValid(note.flyingText) then
			note.flyingText.text = util.fullTrim(note.title) or " "
			note.flyingText.color = util.getColorOrDefault("title", player and player.mod_settings, note) --{black = "white"}
		end
	end,
	isDisabledForEntity = function (entity)
		return config.disableTitle[entity.type]
	end,
	showByDefault = function (note)
		return not note.title
	end
}

components.display = { -- signpost icon display
	create = function (entity)
		local pos = entity.position
		local display = entity.surface.create_entity{
			name = "signpost-display",
			position = { x = pos.x, y = pos.y - 0.3 }
		}
		
		display.operable = false
		display.rotatable = false
		display.destructible = false
		display.minable = false
		
		return display
	end,
	update = function (entity, note)
		local icon = note.icon
		if icon then
			if util.isValid(note.display) then
				note.display.clear_items_inside()
			else
				note.display = components.display.create(entity)
			end
			
			if util.iconHasItem(icon) then note.display.insert(icon.name) end
		else
			util.destroyIfValid(note.display)
		end
	end,
	isDisabledForEntity = function (entity)
		return entity.name ~= "signpost"
	end,
	showByDefault = true
}

components.bpInterface = { -- blueprintable representation of the note (programmable speakers alert message can hold arbitrary blueprintable data)
	create = function (entity)
		local bpInterface = entity.surface.create_entity{
			name = "blueprint-note-interface",
			force = entity.force,
			position = {1000000, 1000000}
		}
		
		bpInterface.teleport(entity.position)
		bpInterface.active = false
		bpInterface.operable = false
		bpInterface.rotatable = false
		bpInterface.destructible = false
		bpInterface.minable = false
		
		-- save unit number in blueprint note interface for entity identification when a blueprint is created of an entity with a note attached
		bpInterface.get_or_create_control_behavior().set_signal(1, { signal = { type = "virtual", name = "signal-0" }, count = entity.unit_number })
		
		return bpInterface
	end,
	getUnitNumber = function (interface)
		return interface.get_control_behavior().get_signal(1).count
	end,
	update = function (entity, note)
		util.destroyIfValid(note.bpInterface)
		note.bpInterface = components.bpInterface.create(entity)
	end,
	isDisabledForEntity = function (entity)
		return config.disableTitle[entity.type]
	end,
	showByDefault = true
}

return components