-- Notes attached to blueprints

local this = {}
local util = scripts.util
local gui = scripts["gui-tools"]
local mod_gui = require("mod-gui")
local tables = require("tables")
local templates = scripts["blueprint-notes.gui-templates"].templates

function this.on_gui_opened(event)
	local index = event.player_index
	local player = game.players[index]
	local cache = global.cache[index]
	local stack = event.item or (cache.editBlueprintGui and cache.editBlueprintGui.inner) or player.blueprint_to_setup
	if cache.editBlueprintGui then cache.editBlueprintGui.init = false end
	
	-- ignore this event when the note of the player.blueprint_to_setup changed
	if cache.openedBlueprintGui and cache.openedBlueprintGui.ignoreGUIRebuild then return end
	
	if util.supportsBpNote(stack) then
		if this.openedBpDiffers(cache, stack) then
			this.buildPreviewGUI(player, cache) -- destroy preview window
			this.buildGUI(player, cache, stack) -- create edit window
		end
		
	elseif cache.openedBlueprintGui then
		this.destroyGUI(player, cache)
	end
end

local function cleanBPsFeatureActive(player)
	return util.mod("PickerExtended") and player.mod_settings["picker-no-blueprint-inv"].value ~= "none"
end

function this.on_gui_closed(event)
	local index = event.player_index
	local player = game.players[index]
	local cache = global.cache[index]
	
	-- ignore this event when the note of the player.blueprint_to_setup changed
	if cache.openedBlueprintGui and cache.openedBlueprintGui.ignoreGUIRebuild then return end
	
	-- editor of blueprint/book has been closed? (only applies to editor opened via edit button/hotkey)
	if cache.editBlueprintGui and not cache.editBlueprintGui.init and event.gui_type == defines.gui_type.item then 
	
		if not cleanBPsFeatureActive(player) then
			this.updateBlueprintRef(player, cache, "editBlueprintGui")
			
			local cursorStack = player.cursor_stack
			local stack = cache.editBlueprintGui and cache.editBlueprintGui.stack
			
			if not cursorStack.valid_for_read and util.isValidStack(stack) then  -- reselect the stack
				cursorStack.transfer_stack(stack)
			end
		end
		
		cache.editBlueprintGui = nil
	end
	
	this.destroyGUI(player, cache)
	this.buildPreviewGUI(player, cache)
end

function this.on_player_setup_blueprint(event)
	local index = event.player_index
	local player = game.players[index]
	local cache = global.cache[index]
	
	if event.alt then -- SHIFT select
		this.buildPreviewGUI(player, cache)
		
	--else -- normal select
		--cache.openedBlueprintGui = this.getDefaultNote(event.item, player)
		--this.buildGUI(player, cache)
	end
end

function this.on_player_cursor_stack_changed(event)
	local index = event.player_index
	local player = game.players[index]
	local cache = global.cache[index]
	
	this.updateBlueprintRef(player, cache)
	this.buildPreviewGUI(player, cache)
end

function this.on_player_main_inventory_changed(event)
	local index = event.player_index
	local player = game.players[index]
	local cache = global.cache[index]
	
	this.updateBlueprintRef(player, cache)
end

function this.on_player_quickbar_inventory_changed(event)
	local index = event.player_index
	local player = game.players[index]
	local cache = global.cache[index]
	
	this.updateBlueprintRef(player, cache)
end

local trackBps = { -- track this stack references from players cache
	"openedBlueprintGui",
	"editBlueprintGui",
}

-- update cache blueprint/book item stack references (incase they got transfered to another item stack)
function this.updateBlueprintRef(player, cache, track) 
	track = track and {track} or trackBps

	if util.isValidPlayer(player) then
		for _,name in ipairs(track) do
			if cache[name] then
				local bp = cache[name]
				
				if bp.stackID then
					if not util.isValidStack(bp.stack) or bp.stackID ~= bp.stack.item_number then
						local found = util.iterateInvs(player, function(stack)
							if stack.item_number == bp.stackID then
								bp.stack = stack
								return true
							end
						end)
						
						if not found then
							this.destroyGUI(player, cache)
						end
					end
				end
			end
		end
	end
end

function this.openedBpDiffers(cache, from)
	if cache.openedBlueprintGui then
		local stack = cache.openedBlueprintGui.stack
		
		if stack and from and stack.item_number ~= nil then
			return stack.item_number ~= from.item_number 
		end
		
		return stack ~= from
	end
	
	return true
end

function this.editSelectedBp(event) -- edit blueprint button and hotkey
	local index = event.player_index
	local player = game.players[index]
	local cache = global.cache[index]
	
	if util.isValidPlayer(player) then
		local stack = player.cursor_stack
		local outer = stack
		
		if stack.is_blueprint_book then
			local inv = stack.get_inventory(defines.inventory.item_main)
			if not inv.is_empty() then stack = inv[stack.active_index] end
		end
		
		if util.supportsBpNote(stack) then
			cache.editBlueprintGui = { -- so on_gui_opened event knows which stack has been opened
				inner = stack,
				stack = outer,
				stackID = outer.item_number,
				init = true,
			}
			player.opened = stack
			
			if cleanBPsFeatureActive(player) or not player.clean_cursor() then
				this.destroyPreviewGUI(player)
			end
		end
	end
end

function this.updateOpenedBp(player, bp)
	if not bp or not bp.stack then return end
	
	local cache = global.cache[player.index]
	local edit = cache.editBlueprintGui
	local doUpdate = edit and (edit.stack == bp.stack) -- don't update stackID if we are encoding the inner bp inside a bp book
						
	local id = this.encodeBlueprint(bp, bp.stack) -- encode (inner) blueprint
	if doUpdate then edit.stackID = id end -- update edit stackID if it changed
	
	bp.stack.allow_manual_label_change = false
	if not util.isValidStack(player.blueprint_to_setup) then player.opened = bp.stack end
end

function this.getIcon(icons, index)
	local refIndex, ref
	for i = 1, 4 do
		refIndex, ref = i, icons[i]
		if ref and ref.index == index then break end
	end
	return refIndex, ref
end

this.on_edit_blueprint = this.editSelectedBp

function this.on_tick() -- update blueprint preview incase bp book active index changed
	util.doEvery(15, this.updatePreview)
end

function this.updatePreview()
	for index,player in pairs(game.players) do
		if util.isValidPlayer(player) and player.connected then
			local cache = global.cache[index]
			local stack = player.cursor_stack
			
			if stack.is_blueprint_book and cache.activeIndex ~= stack.active_index then
				this.buildPreviewGUI(player, cache)
				cache.activeIndex = stack.active_index
			end
		end
	end
end

function this.buildPreviewGUI(player, cache)
	if not util.isValidPlayer(player) then return end

	this.destroyPreviewGUI(player)
	local stack = player.cursor_stack
	if stack.is_blueprint_book then
		local inv = stack.get_inventory(defines.inventory.item_main)
		if not inv.is_empty() then stack = inv[stack.active_index] end
	end
	
	if util.supportsBpNote(stack) and this.openedBpDiffers(cache, stack) then
		gui.create(player, templates.notePreview, { bp = this.decodeBlueprint(stack), settings = player.mod_settings })
	end
end

function this.destroyPreviewGUI(player)
	gui.destroy(player, templates.notePreview)
end

function this.buildGUI(player, cache, opened)
	local bp = opened and this.decodeBlueprint(opened) or cache.openedBlueprintGui
	if bp and bp.stack then bp.stack.allow_manual_label_change = false end
	cache.openedBlueprintGui = bp
	
	gui.create(player, templates.noteWindow, { bp = bp, settings = player.mod_settings })
end

function this.destroyGUI(player, cache)
	gui.destroy(player, templates.noteWindow)
	
	local bp = cache.openedBlueprintGui
	if bp and util.isValidStack(bp.stack) then bp.stack.allow_manual_label_change = bp.note.allowLabelChange end
	cache.openedBlueprintGui = nil
end

function this.encodeBlueprint(bp, stack) -- encode blueprint note to an item stack (returns item number encoded stack)
	local success = stack.set_stack{ name = bp.name }
	if not success then return false end
	local note = bp.note
	
	if bp.index then
		bp.entities[bp.index].alert_parameters.alert_message = this.encodeBlueprintNote(note)
	else
		local index = #bp.entities + 1
		bp.index = index
		bp.entities[index] = {
			name = "blueprint-attached-note",
			entity_number = index,
			position = { 0, 0 },
			alert_parameters = {
				show_alert = false,
				show_on_map = false,
				alert_message = this.encodeBlueprintNote(note)
			}
		}
	end
	
	bp.ignoreGUIRebuild = true
		stack.set_blueprint_entities(bp.entities)
		stack.set_blueprint_tiles(bp.tiles)
		stack.label = note.label or ""
		stack.label_color = util.getColorOrDefault("label", nil, note, {black = "white"})
		stack.allow_manual_label_change = note.allowLabelChange
		stack.blueprint_icons = note.icons
	bp.ignoreGUIRebuild = false
	
	note.icons = stack.blueprint_icons
	bp.stackID = stack.item_number
	return bp.stackID
end

function this.decodeBlueprint(item) -- decode blueprint note from an item stack
	local entities = item.get_blueprint_entities() or {}
	local index, note = this.decodeBlueprintNote(entities)
	
	note.label = item.label
	note.labelColor = item.label_color
	note.icons = item.blueprint_icons
	note.allowLabelChange = item.allow_manual_label_change
	
	return {
		name = item.name,
		entities = entities,
		tiles = item.get_blueprint_tiles(),
		note = note,
		stack = item,
		stackID = item.item_number,
		index = index -- index of the blueprint-attached-note entity in the entities array
	}
end

function this.encodeBlueprintNote(note)
	return serpent.dump(note)
end

function this.decodeBlueprintNote(entities)
	for index,entity in pairs(entities) do
		if entity.name == "blueprint-attached-note" then
			return index, loadstring(entity.alert_parameters.alert_message)()
		end
	end
	return nil, {}
end

function this.on_built_entity(event)
	local entity = event.created_entity
	
	if util.isValid(entity) and entity.type == "entity-ghost" and entity.ghost_name == "blueprint-attached-note" then
		entity.destroy()
	end
end

return this