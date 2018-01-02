-- Makes notes pastable to any entity that can have one

local tables = require("tables")
local util = require("scripts.util")
local pastableEntities = {}

local function collectPastableEntities(tbl)
	for etype,_ in pairs(tbl) do
		local entities = data.raw[etype]
		if entities then
			for _,entity in pairs(entities) do
				pastableEntities[#pastableEntities + 1] = entity.name
			end
		end
	end
end

local function addPastableEntities(tbl)
	for etype,_ in pairs(tbl) do
		local entities = data.raw[etype]
		if entities then
			for _,entity in pairs(entities) do
				entity.allow_copy_paste = true
				if type(entity.additional_pastable_entities) == "string" then
					entity.additional_pastable_entities = util.concat({entity.additional_pastable_entities}, pastableEntities)
				elseif type(entity.additional_pastable_entities) == "table" then
					entity.additional_pastable_entities = util.concat(entity.additional_pastable_entities, pastableEntities)
				else
					entity.additional_pastable_entities = util.shallowCopy(pastableEntities)
				end
			end
		end
	end
end

collectPastableEntities(tables.offerAttachNote)
collectPastableEntities(tables.alwaysAttachNote)

addPastableEntities(tables.offerAttachNote)
addPastableEntities(tables.alwaysAttachNote)