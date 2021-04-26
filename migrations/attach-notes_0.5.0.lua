
local metatables = require("__attach-notes__.scripts.metatables")
metatables.refresh(global)

for __,surface in pairs(game.surfaces) do
	for __,entity in pairs(surface.find_entities_filtered{ name = "blueprint-note-storage-new" }) do
		if entity and entity.valid then 
			entity.destroy() 
		end
	end
	for __,entity in pairs(surface.find_entities_filtered{ ghost_name = "blueprint-note-storage-new" }) do

		log("Attach notes migration 0.5.0: found ghost storage, unitNumber "..entity.unit_number)
		entity.destroy() 
	end
	for __,entity in pairs(surface.find_entities_filtered{ ghost_name = "blueprint-note-interface" }) do

		log("Attach notes migration 0.5.0: found ghost interface, unitNumber "..entity.unit_number)
		entity.destroy() 
	end

	for __,interface in pairs(surface.find_entities_filtered{ name = "blueprint-note-interface" }) do
		if interface and interface.valid then
			local pos = interface.position
			if interface.get_control_behavior() and interface.get_control_behavior().get_signal(1) then

				local unitNumber = interface.get_control_behavior().get_signal(1).count
				local foundEntity = false
				
				for __,entity in pairs(surface.find_entities_filtered{ name = "blueprint-note-interface", position = pos, invert = true }) do

					if entity and entity.valid and entity.unit_number == unitNumber then 
						foundEntity = true
						break
					end
				end

				if foundEntity and not global.notes[unitNumber] then
					interface.destroy()
					log("Attach notes migration 0.5.0: found invalid interface with entity, unitNumber "..unitNumber)

				elseif not foundEntity then 
					local note = global.notes[unitNumber]

					if type(note.marker) == "table" and note.marker.valid then note.marker.destroy() end
					if type(note.mapTag) == "table" and note.mapTag.valid then note.mapTag.destroy() end
					if type(note.flyingText) == "table" and note.flyingText.valid then note.flyingText.destroy() end
					if type(note.display) == "table" and note.display.valid then note.display.destroy() end
					interface.destroy()
					
					global.notes[unitNumber] = nil
					log("Attach notes migration 0.5.0: found invalid interface without entity, unitNumber "..unitNumber)
				end
			else
				interface.destroy()
				log("Attach notes migration 0.5.0: found invalid interface WITHOUT unitNumber")
			end
		end
	end
end


log("Attach notes: Invalid notes cleared")


