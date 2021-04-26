
local metatables = require("__attach-notes__.scripts.metatables")
metatables.refresh(global)

local function isValid(object)
	return type(object) == "table" and object.valid
end

for __,surface in pairs(game.surfaces) do
	for __,entity in pairs(surface.find_entities_filtered{ name = "signpost" }) do

		local note = global.notes[entity]
		if note then
			local icon = note.icon
			if icon then
				if isValid(note.display) then
					note.display.clear_items_inside()
				else
					local pos = entity.position
					local display = entity.surface.create_entity{
						name = "signpost-display",
						position = { x = pos.x, y = pos.y - 0.3 }
					}
					
					display.operable = false
					display.rotatable = false
					display.destructible = false
					display.minable = false
					note.display = display
				end
				
				if icon and icon.name and isValid(game.item_prototypes[icon.name]) then note.display.insert(icon.name) end
			else
				if isValid(note.display) then note.display.destroy() end
			end
			log("Attach notes migration 0.4.8_2: replaced display for signpost '"..(note.title or "?").."'")
		end
	end
end


log("Attach notes: replaced invalid signpost displays")


