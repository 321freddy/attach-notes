local this = {}

local getmetatable, setmetatable, type, rawget, rawset = getmetatable, setmetatable, type, rawget, rawset

function this.uses(obj, name)
    return getmetatable(obj) == this[name]
end

function this.use(obj, name)
	if type(obj) == "table" then 
		rawset(obj, "__mt", name)
		return setmetatable(obj, this[name]) 
	end
end

function this.set(obj, name) -- not persistent
	if type(obj) == "table" then 
		return setmetatable(obj, this[name]) 
	end
end

function this.new(name)
	return setmetatable({ __mt = name }, this[name])
end

function this.refresh(obj)
	if type(obj) == "table" and not obj.__self then 
		for key,val in pairs(obj) do
			this.refresh(val)
		end

		local name = rawget(obj, "__mt")
		if type(name) == "string" then
			local mt = this[name]
			if mt then return setmetatable(obj, mt) end
		end
	end
end

this.entityAsIndex = { -- metatable for using an entity as a table index
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

this.rendering = { -- wrapper metatable for renderings, so they can be used like entities
	__index = function(t, k)
		local id = rawget(t, "__id")

		if k == "id" then 
			return id

		elseif k == "valid" then 
			return rendering.is_valid(id) 

		elseif k == "destroy" then 
			return function()
				if rendering.is_valid(id) then rendering.destroy(id) end
			end
			
		elseif string.sub(k, 4) == "set_" then
			return function(...)
				rendering[k](id, ...) 
			end

		else
			return rendering["get_"..k](id)
		end
	end,
	__newindex = function(t, k, v)
		rendering["set_"..k](rawget(t, "__id"), v)
	end,
}

return this