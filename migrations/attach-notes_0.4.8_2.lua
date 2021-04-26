
local components = scripts.components
local metatables = require("__attach-notes__.scripts.metatables")
metatables.refresh(global)

for __,surface in pairs(game.surfaces) do
	for __,entity in pairs(surface.find_entities_filtered{ name = "signpost" }) do

		local note = global.notes[entity]
		if note then
			components.display.update(entity, note)
			log("Attach notes migration 0.4.8_2: replaced display for signpost '"..(note.title or "?").."'")
		end
	end
end


log("Attach notes: replaced invalid signpost displays")


