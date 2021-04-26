
local metatables = require("__attach-notes__.scripts.metatables")
metatables.refresh(global)

for __,surface in pairs(game.surfaces) do
	for __,entity in pairs(surface.find_entities_filtered{ name = "signpost" }) do
		if entity and entity.valid then
			local pos = entity.position
			local note = global.notes[entity]
			local flyingText = note and note.flyingText 

			if flyingText and flyingText.valid then
				flyingText.teleport({ x = pos.x, y = pos.y + 0.2 })
				log("Attach notes migration 0.4.6: teleported flying text "..entity.unit_number.." '"..flyingText.text.."'")
			end
		end
	end
end


log("Attach notes: Signpost flying text positions updated")


