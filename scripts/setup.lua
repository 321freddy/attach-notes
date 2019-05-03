-- Sets up the global table

local setup = {}
local util = scripts.util
local metatables = scripts.metatables

function setup.on_init()
	global.cache = global.cache or {}
  global.notes = global.notes or {}
	metatables.use(global.notes, "entityAsIndex")
	
	-- GUI events are saved in global.guiEvents["EVENT NAME"][PLAYER INDEX][GUI ELEMENT INDEX]
	global.guiEvents = global.guiEvents or { onCheckedStateChanged = {},
											 onClicked = {},
											 onElementChanged = {},
											 onSelectionStateChanged = {},
											 onTextChanged = {},
											 onValueChanged = {} }
											 
	-- Migration to version 0.2.2
	global.guiEvents.onValueChanged = global.guiEvents.onValueChanged or {}
	
	-- Create player caches
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
	metatables.refresh(global)
end

return setup