-- Sets up the global table

local setup = {}
local util = scripts.util

local entityAsIndex = { -- metatable for using an entity as a table index
	__index = function (tbl, entity)
		if type(entity) == "table" and entity.valid then
			local id = entity.unit_number
			
			if id then
				local tblId = rawget(tbl, "id")
				if tblId then return tblId[id] end
			else
				local pos = entity.position
				local index = table.concat({ entity.surface.index, pos.x, pos.y }, ";")
				local tblPos = rawget(tbl, "pos")
				if tblPos then return tblPos[index] end
			end
		elseif type(entity) == "number" then -- index is unit number
			local tblId = rawget(tbl, "id")
			if tblId then return tblId[entity] end
		end
    end,
	
	__newindex = function (tbl, entity, value)
		local count = rawget(tbl, "count") or 0
		
		local id
		if type(entity) == "number" then -- index is unit number
			id = entity
		else
			id = entity.unit_number
		end
		
		if id then -- entities indexed by unit number
			local tblId = rawget(tbl, "id")
			
			if tblId then 
				local oldvalue = tblId[id]
				if value ~= oldvalue then
					if value == nil then
						rawset(tbl, "count", count - 1)
					else
						rawset(tbl, "count", count + 1)
					end
					
					tblId[id] = value
				end
			elseif value ~= nil then
				rawset(tbl, "id", { [id] = value })
				rawset(tbl, "count", count + 1)
			end
		else -- other entities that don't support unit number indexed by their surface and position
			local pos = entity.position
			local index = table.concat({ entity.surface.index, pos.x, pos.y }, ";")
			local tblPos = rawget(tbl, "pos")
			
			if tblPos then 
				local oldvalue = tblPos[index]
				if value ~= oldvalue then
					if value == nil then
						rawset(tbl, "count", count - 1)
					else
						rawset(tbl, "count", count + 1)
					end
					
					tblPos[index] = value
				end
			elseif value ~= nil then
				rawset(tbl, "pos", { [index] = value })
				rawset(tbl, "count", count + 1)
			end
		end
    end,
	
	__len = function (tbl)
		return rawget(tbl, "count") or 0
	end
}

function setup.on_init()
	global.cache = global.cache or {}
	global.notes = global.notes or setup.newEAITable()
	
	-- GUI events are saved in global.guiEvents["EVENT NAME"][PLAYER INDEX][GUI ELEMENT INDEX]
	global.guiEvents = global.guiEvents or { onCheckedStateChanged = {},
											 onClicked = {},
											 onElementChanged = {},
											 onSelectionStateChanged = {},
											 onTextChanged = {} }
	
	for player_index,_ in pairs(game.players) do
		setup.createPlayerCache(player_index)
	end
end

setup.on_configuration_changed = setup.on_init

function setup.on_player_created(event)
	setup.createPlayerCache(event.player_index)
end

function setup.createPlayerCache(index)
	global.cache[index] = global.cache[index] or {}
end

function setup.on_load()
	setup.useEntityAsIndex(global.notes)
end

function setup.useEntityAsIndex(tbl)
	if tbl then setmetatable(tbl, entityAsIndex) end
end

function setup.newEAITable() -- creates new table with entity as index
	local tbl = {}
	setup.useEntityAsIndex(tbl)
	return tbl
end

return setup