-- GUI templates for blueprint-attached notes

local this = {templates = {}}
local util = scripts.util
local components = scripts.components
local tables = require("tables")
local gui = scripts["gui-tools"]
local controller

local function createNoteGuiElement(data)
	return {
		type = data.type,
		name = data.name,
		caption = data.caption or {"attach-notes-gui."..data.name},
		style = data.style,
		state = data.state,
		elem_type = data.elem_type,
		sprite = data.sprite,
		items = data.items,
		unique = data.unique,
		children = data.children,
		onCreated = data.onCreated,
		onChanged = function (event)
			local index = event.player_index
			local player = game.players[index]
			local cache = global.cache[index]
			local bp = cache.openedBlueprintGui
			
			if data.onChanged then data.onChanged(event, index, player, cache, bp) end
		end
	}
end

local function createColorPickerButton(name, getTarget, getFrame, onCreated)
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
				local color = util.getColorOrDefault(name, data.settings, data.bp.note)
				self.style.font_color = color
				self.style.hovered_font_color = color
				self.style.clicked_font_color = color
				if onCreated then onCreated(self) end
			end
		end,
		onClicked = function (event)
			local frame = getFrame(event.element).style
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
			self.style.visible = false
		end,
		children = {
			{
				type = "table",
				name = name.."-color-picker-table",
				column_count = #tables.colors,
				style = "color_picker_table_style",
				children = {}
			}
		}
	}
	
	local tableChildren = frame.children[1].children
	for i,color in ipairs(tables.colors) do
		tableChildren[i] = createNoteGuiElement{
			type = "button",
			name = name.."-color-"..color,
			tooltip = { "colors."..color },
			caption = "█",
			style = "color_button_style",
			onCreated = function (self, data)
				self.style.font_color = tables.colorFromName[color]
				self.style.hovered_font_color = self.style.font_color
				self.style.clicked_font_color = self.style.font_color
			end,
			onChanged = function (event, index, player, cache, bp)
				local self = event.element
				
				bp.note[name.."Color"] = i
				self.parent.parent.style.visible = false
				onColorChanged(self.parent.parent, self.style.font_color, bp, player)
			end
		}
	end
	
	return frame
end

local function createSettingsFlow(data)
	return {
		type = "flow",
		name = data.name.."-settings",
		direction = data.direction or "horizontal",
		onCreated = function (self, _data)
			if #self.children == 0 then
				self.destroy()
			else
				self.style.horizontally_stretchable = true
			end
			
			if data.onCreated then data.onCreated(self, _data) end
		end,
		children = data.children
	}
end

local function createSlotIcon(index)
	return createNoteGuiElement{
		type = "sprite-button", -- simple sprites don't support dynamic sprite changing
		name = "slot-icon",
		caption = "      ",
		style = "icon_style",
		unique = false,
		onCreated = function(self, data)
			local note = data.bp.note
			local style = self.style
			
			if note and note.icons[index] then 
				-- load the correct icon sprite
				self.sprite = "item/"..note.icons[index].signal.name
				style.visible = true
				
				-- icon layouting inside the blueprint slot is done by changing padding values
				local count = table_size(note.icons)
				local size = 76 / 3 + 5
				
				if index % 2 == 0 then -- 2 and 4
					style.left_padding = size
					style.right_padding = 0
				else -- 1 and 3
					style.left_padding = 3
					style.right_padding = size
				end
				
				if index > 2 then -- 3 and 4
					style.top_padding = size
					style.bottom_padding = 0
				else -- 1 and 2
					style.top_padding = 0
					style.bottom_padding = size
				end
				
				if count <= 2 then -- center and resize elements if needed
				
					style.top_padding = size / 2 -- center vertically
					style.bottom_padding = size / 2
					
					if count == 1 then -- center horizontally and enlarge
						style.top_padding = size / 2 - 3
						style.left_padding = size / 2 - 3
						style.right_padding = size / 2
						self.caption = ""
						style.width = 65
						style.height = 65
					end
				end
				
				style.scaleable = false
				style.horizontally_stretchable = false
				style.vertically_stretchable = false
				style.horizontally_squashable = false
				style.vertically_squashable = false
			else 
				style.visible = false
			end
		end,
	}
end

this.templates.blueprintSlot = createNoteGuiElement{
	type = "sprite-button",
	name = "slot-button",
	sprite = "item/blueprint",
	style = "blueprint_record_slot_button",
	caption = "",
	onCreated = function (self, data)
		self.style.align = "center"
		self.style.vertical_align = "center"
		self.sprite = "item/"..data.bp.name
	end,
	onChanged = function (event, index, player, cache, bp)
		if not bp or event.element.parent.name ~= "slot-wrapper" then return end
	
		-- destroy and recreate this slot button (position can be preserved by wrapping the button inside a flow)
		gui.create(player, this.templates.blueprintSlot, {bp = bp}, event.element.parent)
	end,
	children = (function() -- create 4 blueprint slot icons
		local children = {}
		for i = 1, 4 do children[i] = createSlotIcon(i) end
		return children
	end)(),
}

local function createIconChooser(btnIndex, getTarget)
	return createNoteGuiElement{
		type = "choose-elem-button",
		name = "icon-chooser",
		elem_type = "signal",
		unique = false,
		onCreated = function (self, data)
			local note = data.bp.note
			if note then
				local refIndex, ref = controller.getIcon(note.icons, btnIndex)
				if ref then self.elem_value = ref.signal end
			end
		end,
		onChanged = function (event, index, player, cache, bp)
			local self = event.element
			local icon = event.element.elem_value
			local note = bp.note
			local refIndex, ref = controller.getIcon(note.icons, btnIndex) -- get icon reference
			
			if icon then -- update icon in icon list of note
				if not ref then 
					ref = { index = btnIndex }
					note.icons[#note.icons + 1] = ref
				end
				ref.signal = event.element.elem_value
				
			elseif ref then
				note.icons[refIndex] = nil
			end
			
			local rebuild = table_size(note.icons) == 0
			controller.updateOpenedBp(player, bp) -- update vanilla blueprint gui (+ reorder icons)
			
			if rebuild then -- icon choosers need update
				controller.buildGUI(player, cache) -- rebuild entire gui
			else
				gui.on_gui_click{ -- update blueprint slot button icons
					element = getTarget(self),
					player_index = index,
				}
			end
		end,
	}
end
		
this.templates.noteWindow = {
	type = "frame",
	name = "blueprint-note-window",
	direction = "vertical",
	onCreated = function (self, data)
		self.caption = {"attach-notes-gui.blueprint-caption", game.item_prototypes[data.bp.name].localised_name}
	end,
	children = {
		createSettingsFlow{
			name = "header",
			children = {
				{
					type = "flow",
					name = "slot-wrapper",
					children = {
						this.templates.blueprintSlot,
					}
				},
				createSettingsFlow{
					name = "tag",
					direction = "vertical",
					children = {
						createSettingsFlow{
							name = "label",
							children = {
								createNoteGuiElement{
									type = "textfield",
									name = "label",
									onCreated = function (self, data)
										local note = data.bp.note
										if note and note.label then self.text = note.label end
										
										self.tooltip = { "tooltips.label" }
										self.style = "entity_title_style_op"..data.settings.opacity.value
										self.style.font_color = util.getColorOrDefault("label", data.settings, note)
										self.style.width = 4 * 40 + 29
									end,
									onChanged = function (event, index, player, cache, bp)
										local text = event.element.text
										bp.note.label = #text > 0 and text or nil
										controller.updateOpenedBp(player, bp)
									end
								},
							}
						},
						createSettingsFlow{
							name = "icon",
							children = (function() -- create 4 blueprint icon choosers
								local children = {}
								for i = 1, 4 do 
									children[i] = createIconChooser(i, 
										function(self) return self.parent.parent.parent["slot-wrapper"]["slot-button"] end)
								end
								
								children[5] = createColorPickerButton("label", 
									function(self) return self.parent.parent["label-settings"].label end, -- getTarget
									function(self) return self.parent.parent.parent.parent["label-color-picker-frame"] end) -- getFrame
									
								return children
							end)(),
						},
					}
				},
			}
		},
		createColorPickerFrame("label", function (self, color, bp, player)
			local tagSettings = self.parent["header-settings"]["tag-settings"]
			local label = tagSettings["label-settings"].label.style
			local pickerButton = tagSettings["icon-settings"]["label-color-picker-button"].style
			pickerButton.font_color = color
			pickerButton.hovered_font_color = color
			pickerButton.clicked_font_color = color
			label.font_color = color
			controller.updateOpenedBp(player, bp)
		end),
		createNoteGuiElement{
			type = "text-box",
			name = "note-text",
			onCreated = function (self, data)
				local note = data.bp.note
				if note and note.text then self.text = note.text end
				self.style = "entity_note_style_op"..data.settings.opacity.value
				self.style.font_color = util.getColorOrDefault("text", data.settings, note)
			end,
			onChanged = function (event, index, player, cache, bp)
				local text = event.element.text
				bp.note.text = #text > 0 and text or nil
				controller.updateOpenedBp(player, bp)
			end
		},
		createSettingsFlow{
			name = "text",
			children = {
				createNoteGuiElement{
					type = "drop-down",
					name = "font",
					style = "font_settings_style",
					items = util.concat{{{"attach-notes-gui.select-font"}}, util.localize(tables.fonts, "fonts")},
					onCreated = function (self, data)
						local textBox, note = self.parent.parent["note-text"], data.bp.note -- update text box font
						if note and note.font then
							textBox.style.font = tables.fonts[note.font]
							self.selected_index = note.font + 1
						else
							textBox.style.font = data.settings["default-font"].value
							self.selected_index = 1
						end
					end,
					onChanged = function (event, index, player, cache, bp)
						local self = event.element
						local note = bp.note
						local selected = event.element.selected_index
						
						if selected > 1 then -- save changes
							note.font = selected - 1
						else
							note.font = nil
						end
						
						local textBox = self.parent.parent["note-text"] -- update text box font
						if note and note.font then
							textBox.style.font = tables.fonts[note.font]
							self.selected_index = note.font + 1
						else
							textBox.style.font = player.mod_settings["default-font"].value
							self.selected_index = 1
						end
						
						controller.updateOpenedBp(player, bp)
					end
				},
				createColorPickerButton("text", 
					function (self) return self.parent.parent["note-text"] end, -- getTarget
					function(self) return self.parent.parent["text-color-picker-frame"] end, -- getFrame
					function (self) -- onCreated
						self.style.font = "color-picker-button"
						self.caption = self.caption..self.caption
						self.style.top_padding = 0
					end)
			}
		},
		createColorPickerFrame("text", function (self, color, bp, player)
			local parent = self.parent
			local pickerButton = parent["text-settings"]["text-color-picker-button"].style
			pickerButton.font_color = color
			pickerButton.hovered_font_color = color
			pickerButton.clicked_font_color = color
			parent["note-text"].style.font_color = color
			controller.updateOpenedBp(player, bp)
		end),
		--[[createSettingsFlow{ -- destroy on disableTitle
			name = "component",
			children = {
			}
		}]]--
	}
}

this.templates.notePreview = {
	type = "frame",
	name = "blueprint-note-preview",
	direction = "vertical",
	children = {
		createSettingsFlow{
			name = "frame-header",
			children = {
				{
					type = "label",
					name = "frame-caption",
					onCreated = function (self, data)
						self.caption = {"attach-notes-gui.blueprint-caption", game.item_prototypes[data.bp.name].localised_name}
						local style = self.style
						style.bottom_padding = 5
						style.font = "default-frame"
					end,
				},
				{
					type = "sprite-button", -- invisible
					name = "spacer",
					style = "icon_style",
					onCreated = function (self, data)
						self.enabled = false
						self.style.horizontally_stretchable = true
						self.style.horizontally_squashable = true
					end,
				},
				{
					type = "sprite-button",
					name = "edit",
					style = "attach-notes-edit-button",
					onCreated = function (self, data)
						self.tooltip = { "tooltips.edit-blueprint" }
					
						local style = self.style
						style.width = 32
						style.height = 32
						style.top_padding = 0
						style.bottom_padding = 0
						style.font = "default-bold"
					end,
					onChanged = function (event)
						controller.editSelectedBp(event)
					end,
				},
			},
		},
		createSettingsFlow{
			name = "tag",
			children = {
				this.templates.blueprintSlot,
				createNoteGuiElement{
					type = "label",
					name = "title",
					caption = "",
					onCreated = function (self, data)
						local note = data.bp.note
						if note and note.label then self.caption = util.fullTrim(note.label)
						else self.caption = game.item_prototypes[data.bp.name].localised_name end
						
						self.tooltip = { "tooltips.label" }
						self.style.font = "default-large-bold"
						self.style.font_color = util.getColorOrDefault("label", data.settings, note, {black = "white"})
						self.style.single_line = true
					end,
				},
			}
		},
		createNoteGuiElement{
			type = "label",
			name = "note-text",
			caption = "",
			onCreated = function (self, data)
				local note = data.bp.note
				if note and note.text then self.caption = util.fullTrim(note.text) end
				self.style.font_color = util.getColorOrDefault("text", data.settings, note, {black = "white"})
				
				if note and note.font then
					self.style.font = tables.fonts[note.font]
				else
					self.style.font = data.settings["default-font"].value
				end
		
				self.style.single_line = false
			end,
		},
	}
}

return {this, function(_controller) controller = _controller end}