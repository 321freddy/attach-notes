local config = require("config")
local player = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaPlayer --

function player:setting(name)
    return self.mod_settings[name].value
end

function player:playercontents()
	local contents     = self:contents("main")
	local cursor_stack = self.cursor_stack
	
	if cursor_stack.valid_for_read then
		local item = cursor_stack.name
		contents[item] = (contents[item] or 0) + cursor_stack.count
	end
		   
	return contents
end