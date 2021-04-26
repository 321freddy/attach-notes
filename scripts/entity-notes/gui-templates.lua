-- GUI templates for entity-attached notes

local this = {templates = {}}
local util = scripts.util
local components = scripts.components
local config = require("config")
local gui = scripts["gui-tools"]
local controller

this.templates.attachNoteButton = {
	type = "sprite-button",
	name = "attach-note-button",
	onCreated = function (self, data)
		if data.attached then
			-- Show "show note" button
			self.style = "attach-notes-view-button"
			self.tooltip = { "tooltips.view-note" }
		else
			-- Show "add note" button
			self.style = "attach-notes-add-button"
			self.tooltip = { "tooltips.attach-note", data.opened.localised_name }
		end
		
		self.style.width = 36
		self.style.height = 36
	end,
	onClicked = function (event)
		local player = event.element.gui.player
		local settings = player.mod_settings
		local notes = global.notes
		local cache = global.cache[player.index]
		local opened = cache.openedEntityGui
		
		if notes[opened] then
		
			cache.noteIsHidden = not cache.noteIsHidden -- toggle hidden state if note is present
		else
			notes[opened] = {} -- create new note if no note is present
			
			local note = notes[opened]
			local setting = player.mod_settings["show-marker-by-default"].value
			if setting and not components.marker.isDisabledForEntity(opened) then -- create marker if necessary
				if not util.isValid(note.marker) then note.marker = components.marker.create(opened) end
			end
			
			cache.noteIsHidden = false
		end
		
		controller.buildGUI(player, cache) -- rebuild gui
		opened.last_user = player
	end
}

local function createNoteGuiElement(data)
	return {
		type = data.type,
		name = data.name,
		caption = data.caption or {"attach-notes-gui."..data.name},
		style = data.style,
		state = data.state,
		elem_type = data.elem_type,
		sprite = data.sprite,
		onCreated = data.onCreated,
		onChanged = function (event)
			local index = event.player_index
			local player = game.players[index]
			local cache = global.cache[index]
			local entity = cache.openedEntityGui
			local notes = global.notes
			
			if not util.isValid(entity) then return end
			notes[entity] = notes[entity] or {}
			entity.last_user = player
			
			if data.onChanged then data.onChanged(event, index, player, cache, entity, notes[entity]) end
		end
	}
end

local function createColorPickerButton(name, getTarget, onCreated)
	return {
		type = "button",
		name = name.."-color-picker-button",
		tooltip = { "tooltips."..name.."-color" },
		caption = "█",
		style = "color_picker_button_style",
		onCreated = function (self, data)
			if not getTarget(self) then
				self.destroy()
			else
				local color = util.getColorOrDefault(name, data.settings, data.note)
				self.style.font_color = color
				self.style.hovered_font_color = color
				self.style.clicked_font_color = color
				if onCreated then onCreated(self) end
			end
		end,
		onClicked = function (event)
			local frame = event.element.parent.parent[name.."-color-picker-frame"]
			frame.visible = not frame.visible
		end
	}
end

local function createColorPickerFrame(name, onColorChanged)
	local frame = {
		type = "frame",
		name = name.."-color-picker-frame",
		direction = "horizontal",
		style = "color_picker_frame_style",
		onCreated = function (self, data)
			self.visible = false
		end,
		children = {
			{
				type = "table",
				name = name.."-color-picker-table",
				column_count = #config.colors,
				style = "color_picker_table_style",
				children = {}
			}
		}
	}
	
	local tableChildren = frame.children[1].children
	for i,color in ipairs(config.colors) do
		tableChildren[i] = createNoteGuiElement{
			type = "button",
			name = name.."-color-"..color,
			tooltip = { "colors."..color },
			caption = "█",
			style = "color_button_style",
			onCreated = function (self, data)
				self.style.font_color = config.colorFromName[color]
				self.style.hovered_font_color = self.style.font_color
				self.style.clicked_font_color = self.style.font_color
			end,
			onChanged = function (event, index, player, cache, entity, note)
				local self = event.element
				
				note[name.."Color"] = i
				self.parent.parent.visible = false
				onColorChanged(self.parent.parent, self.style.font_color, note, player)
			end
		}
	end
	
	return frame
end

local function createLinkedElement(data) -- creates gui elements which create or update some of the note components (components.lua)
	return createNoteGuiElement{
		type = data.type,
		name = data.name,
		style = data.style,
		state = data.state,
		elem_type = data.elem_type,
		sprite = data.sprite,
		caption = data.caption,
		onCreated = function (self, onCreatedData)
			if data.update then -- element is only disabled if all existing components are disabled for the opened entity
				local enabled = false
				for _,component in ipairs(data.update) do
					if not components[component].isDisabledForEntity(onCreatedData.opened or onCreatedData.selected) then
						enabled = true
						break
					end
				end
				if not enabled then
					self.destroy()
					return
				end
			end
			
			if data.onCreated then data.onCreated(self, onCreatedData) end
		end,
		onChanged = function (event, index, player, cache, entity, note)
			if data.create then -- create components if 'by default' setting is enabled
				for _,name in ipairs(data.create) do 
					local component = components[name]
					local showByDefault = component.showByDefault
					
					if (showByDefault == true or showByDefault(note)) and not component.isDisabledForEntity(entity) then
						local setting = player.mod_settings["show-"..name.."-by-default"]
						if not setting or (setting and setting.value) then
							if not util.isValid(note[name]) then note[name] = component.create(entity, note, player) end
							if data.getComponentSettings then
								local checkbox = data.getComponentSettings(event.element)["show-"..name.."-checkbox"]
								if checkbox then checkbox.state = true end
							end
						end
					end
				end
			end
			
			-- do element specific updates
			if data.onChanged then data.onChanged(event, index, player, cache, entity, note) end
			
			if data.update then -- update components
				for _,name in ipairs(data.update) do
					components[name].update(entity, note, player)
				end
			end
		end
	}
end

local function createComponentCheckbox(name)
	return createNoteGuiElement{
		type = "checkbox",
		name = "show-"..name.."-checkbox",
		state = false,
		onCreated = function (self, data)
			if components[name].isDisabledForEntity(data.opened or data.selected) then
				self.destroy()
			else
				local note = data.note
				if note then
					self.state = util.isValid(note[name])
				end
			end
		end,
		onChanged = function (event, index, player, cache, entity, note)
			if event.element.state then
				if not util.isValid(note[name]) then
					note[name] = components[name].create(entity, note, player)
				end
			else
				util.destroyIfValid(note[name])
			end
		end
	}
end

local function createSettingsFlow(data)
	return {
		type = "flow",
		name = data.name.."-settings",
		direction = data.direction or "horizontal",
		onCreated = function (self, onCreatedData)
			if #self.children == 0 then
				self.destroy()
			else
				self.style.horizontally_stretchable = true
			end

			if data.onCreated and self and self.valid then data.onCreated(self, onCreatedData) end
		end,
		children = data.children
	}
end

this.templates.noteWindow = {
	type = "frame",
	name = "note-window",
	direction = "vertical",
	children = {
		createSettingsFlow{
			name = "frame-header",
			onCreated = function (self, data)
				self.style.vertical_align = "center"
				self.style.bottom_margin = 8
			end,
			children = {
				{
					type = "label",
					name = "frame-caption",
					style = "heading_1_label",
					onCreated = function (self, data)
						self.caption = data.opened.localised_name
					end,
				},
				{
					type = "flow", -- invisible spacer
					name = "spacer",
					direction = "horizontal",
					onCreated = function (self, data)
						self.style.horizontally_stretchable = true
						self.style.horizontally_squashable = true
					end,
				},
				createNoteGuiElement{
					type = "sprite-button",
					name = "delete",
					style = "attach-notes-delete-button",
					caption = "",
					onCreated = function (self, data)
						self.tooltip = { "tooltips.delete-note" }
					
						local style = self.style
						style.width = 32
						style.height = 32
						style.top_padding = 0
						style.bottom_padding = 0
						style.font = "default-bold"
					end,
					onChanged = function (event, index, player, cache, entity, note) -- delete note
						for name in pairs(components) do util.destroyIfValid(note[name]) end
						global.notes[entity] = nil
						controller.buildGUI(player, cache)
					end,
				},
			},
		},
		createSettingsFlow{
			name = "tag",
			onCreated = function (self, data)
				self.style.vertical_align = "center"
				self["title-color-picker-button"].style.top_margin = 2
			end,
			children = {
				createLinkedElement{
					type = "choose-elem-button",
					name = "icon-chooser",
					elem_type = "signal",
					create = { "mapTag", "bpInterface" },
					update = { "mapTag", "display" },
					onCreated = function (self, data)
						local note = data.note
						if note then
							if util.isValid(note.mapTag) then note.icon = note.mapTag.icon end
							self.elem_value = note.icon
							components.display.update(data.opened, note)
						end
					end,
					onChanged = function (event, index, player, cache, entity, note)
						if not event.element.elem_value or event.element.elem_value.name then
							note.icon = event.element.elem_value
						else
							event.element.elem_value = note and note.icon
						end

						if note and not note.title and note.icon then
							--raises event to call onChanged on title field after translation
							cache.translateTarget = event.element.parent.title

							local proto = game.item_prototypes[note.icon.name] or
										  game.entity_prototypes[note.icon.name] or
										  game.fluid_prototypes[note.icon.name] or
										  game.virtual_signal_prototypes[note.icon.name] or
										  game.tile_prototypes[note.icon.name]

							if proto then player.request_translation(proto.localised_name) end
						end
					end,
				},
				createLinkedElement{
					type = "textfield",
					name = "title",
					create = { "flyingText", "mapTag", "bpInterface" },
					update = { "flyingText", "mapTag" },
					onCreated = function (self, data)
						local note = data.note
						if note then
							if util.isValid(note.mapTag) then
								local newTitle = util.trim(note.mapTag.text)
								if #newTitle > 0 then note.title = newTitle end
							end
							if note.title then self.text = note.title end
						end
						
						self.tooltip = { "tooltips.title" }
						self.style = "entity_title_style"
						self.style.font_color = util.getColorOrDefault("title", data.settings, note)
						self.style.height = 32

						if util.isValid(self.parent["icon-chooser"]) then -- shorten width if necessary
							self.style.width = 237 - 40
						end
					end,
					onChanged = function (event, index, player, cache, entity, note)
						local text = event.element.text
						note.title = #text > 0 and text or nil
					end,
					getComponentSettings = function (self)
						return self.parent.parent["component-settings"]
					end
				},
				createColorPickerButton("title", function (self) return self.parent.title end)
			}
		},
		createColorPickerFrame("title", function (self, color, note, player)
			local tagSettings = self.parent["tag-settings"]
			local pickerButton = tagSettings["title-color-picker-button"].style
			pickerButton.font_color = color
			pickerButton.hovered_font_color = color
			pickerButton.clicked_font_color = color
			tagSettings.title.style.font_color = color
			
			components.flyingText.update(nil, note, player)
		end),
		createLinkedElement{
			type = "text-box",
			name = "note-text",
			create = { "marker", "bpInterface" },
			onCreated = function (self, data)
				local note = data.note
				if note and note.text then
					local text = note.text

					if string.sub(text, -1) ~= "\n" then -- ensure note has newline at end of text
						text = text.."\n"
					end

					self.text = text
				end
				self.style = "entity_note_style"
				self.style.font_color = util.getColorOrDefault("text", data.settings, note)
			end,
			onChanged = function (event, index, player, cache, entity, note)
				local text = event.element.text
				note.text = text
			end,
			getComponentSettings = function (self)
				return self.parent["component-settings"]
			end
		},
		createSettingsFlow{
			name = "text",
			children = {
				{
					type = "drop-down",
					name = "font",
					style = "font_settings_style",
					items = util.concat({{"attach-notes-gui.select-font"}}, util.localize(config.fonts, "fonts")),
					onCreated = function (self, data)
						local textBox, note = self.parent.parent["note-text"], data.note -- update text box font
						if note and note.font then
							textBox.style.font = config.fonts[note.font]
							self.selected_index = note.font + 1
						else
							textBox.style.font = data.settings["default-font"].value
							self.selected_index = 1
						end

						local text = textBox.text -- fix game not applying font correctly
						textBox.text = ""
						textBox.text = text
					end,
					onSelectionStateChanged = function (event)
						local index = event.player_index
						local player = game.players[index]
						local cache = global.cache[index]
						local entity = cache.openedEntityGui
						local notes = global.notes
						local selected = event.element.selected_index
						
						if not util.isValid(entity) then return end
						notes[entity] = notes[entity] or {}
						entity.last_user = player
						
						if selected > 1 then -- save changes
							notes[entity].font = selected - 1
						else
							notes[entity].font = nil
						end
						
						controller.buildGUI(player, cache, entity) -- rebuild gui
					end
				},
				createColorPickerButton("text", function (self) return self.parent.parent["note-text"] end,
					function (self) -- onCreated
						self.caption = self.caption..self.caption
						self.style.top_padding = 0
					end)
			}
		},
		createColorPickerFrame("text", function (self, color)
			local parent = self.parent
			local pickerButton = parent["text-settings"]["text-color-picker-button"].style
			pickerButton.font_color = color
			pickerButton.hovered_font_color = color
			pickerButton.clicked_font_color = color
			parent["note-text"].style.font_color = color
		end),
		createSettingsFlow{ -- destroy on disableTitle
			name = "component",
			children = {
				createComponentCheckbox("marker"),
				createComponentCheckbox("flyingText"),
				createComponentCheckbox("mapTag"),
				--createComponentCheckbox("bpInterface")
			}
		}
	}
}

this.templates.notePreview = {
	type = "frame",
	name = "note-preview",
	direction = "vertical",
	onCreated = function (self, data)
		local entity = data.selected
		if entity.type == "entity-ghost" then
			self.caption = {"attach-notes-gui.ghost-caption", entity.ghost_localised_name}
		else
			self.caption = entity.localised_name
		end
	end,
	children = {
		createSettingsFlow{
			name = "tag",
			onCreated = function (self, data)
				self.style.vertical_align = "center"
				self.style.bottom_margin = 2
			end,
			children = {
				createLinkedElement{
					type = "sprite-button", -- simple sprites don't support dynamic sprite changing
					name = "icon",
					caption = "        ",
					style = "icon_style",
					create = { "mapTag", "bpInterface" },
					onCreated = function (self, data)
						self.style.right_margin = 4
						local note = data.note
						if note and note.icon and note.icon.name and game.is_valid_sprite_path("item/"..note.icon.name) then 
							self.sprite = "item/"..note.icon.name 
						else 
							self.destroy() 
						end
					end,
				},
				createLinkedElement{
					type = "label",
					name = "title",
					caption = "",
					create = { "flyingText", "mapTag", "bpInterface" },
					update = { "flyingText", "mapTag" },
					onCreated = function (self, data)
						local note = data.note
						if note then
							if util.isValid(note.mapTag) then
								local newTitle = util.trim(note.mapTag.text)
								if #newTitle > 0 then note.title = newTitle end
							end
							if note.title then self.caption = util.fullTrim(note.title) end
						end
						
						self.tooltip = { "tooltips.title" }
						self.style.font = "default-large-bold"
						self.style.font_color = util.getColorOrDefault("title", data.settings, note) --{black = "white"}
						self.style.single_line = true
					end,
				},
			}
		},
		createLinkedElement{
			type = "label",
			name = "note-text",
			caption = "",
			create = { "marker", "bpInterface" },
			onCreated = function (self, data)
				local note = data.note
				if note and note.text then self.caption = util.fullTrim(note.text) end
				self.style.font_color = util.getColorOrDefault("text", data.settings, note) --{black = "white"}
				
				local note = data.note -- update text box font
				if note and note.font then
					self.style.font = config.fonts[note.font]
				else
					self.style.font = data.settings["default-font"].value
				end
		
				self.style.single_line = false
			end,
		},
	}
}

return {this, function(_controller) controller = _controller end}