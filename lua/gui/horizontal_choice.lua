--
-- Horizontal selection dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

-- GENERAL NOTE:
--
-- This dialog has a "contextual" mode which is used specifically to mimic
-- what it would look like if it were part of an actual context menu.
--
-- A big limitation in Wesnoth 1.18 is that we cannot detect mouse clicks
-- taking place outside of the window frame, which is the method the standard
-- context menu/gui.show_menu dialog uses in order to get around click_dismiss
-- being incompatible with interactive widgets such as [listbox]. So instead
-- we use a normal dialog with a minimal frame (the "menu" definition) and a
-- smaller close button, as well as some widget swaps depending on which mode
-- was requested by the API.

local option_list_item = {
	T.row {
		T.column {
			horizontal_alignment = "center",
			vertical_alignment = "center",
			border = "all",
			border_size = 5,
			T.image {
				id = "icon",
				linked_group = "option_icons"
			}
		}
	},
	T.row {
		T.column {
			horizontal_grow = true,
			border = "all",
			border_size = 5,
			T.label {
				id = "label",
				definition = "default_small",
				wrap = true,
				text_alignment = "center",
				linked_group = "option_labels"
			}
		}
	},
	T.row {
		T.column {
			horizontal_grow = true,
			border = "all",
			border_size = 5,
			T.label {
				id = "description",
				wrap = true,
				text_alignment = "center",
				linked_group = "option_descriptions"
			}
		}
	}
}

local option_list_def = {
	T.row {
		T.column {
			T.toggle_panel {
				id = "toggle_panel",
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 10,
							T.grid(option_list_item)
						}
					}
				}
			}
		}

	}
}

local choice_dlg = {
	maximum_width = 800,
	maximum_height = 600,

	T.helptip { id="tooltip" },
	T.tooltip { id="tooltip" },

	T.linked_group {
		id = "option_icons",
		fixed_width = true,
		fixed_height = true
	},
	T.linked_group {
		id = "option_labels",
		fixed_width = true,
		fixed_height = true
	},
	T.linked_group {
		id = "option_descriptions",
		fixed_width = true,
		fixed_height = true
	},

	T.grid {
		T.row {
			grow_factor = 0,
			T.column {
				grow_factor = 1,
				horizontal_grow = true,
				border = "all",
				border_size = 5,
				T.label {
					id = "title",
					definition = "title",
					label = "dialog title"
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_grow = true,
				T.grid {
					T.row {
						T.column {
							grow_factor = 1,
							horizontal_grow = true,
							border = "top,left,right",
							border_size = 5,
							T.label {
								id = "title_small",
								definition = "gold",
								label = "dialog title"
							}
						},
						T.column {
							grow_factor = 0,
							horizontal_alignment = "right",
							border = "top,left,right",
							border_size = 5,
							T.button {
								id = "cancel_small",
								definition = "naia_mini_close",
								label = wgettext("Close")
							}
						}
					}
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_grow = true,
				border = "all",
				border_size = 5,
				T.label {
					id = "message",
					wrap = true
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				horizontal_alignment = "center",
				border = "all",
				border_size = 5,
				T.horizontal_listbox {
					id = "option_list",
					T.list_definition(option_list_def)
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_alignment = "right",
				border = "top",
				T.grid {
					T.row {
						T.column {
							grow_factor = 0,
							border = "all",
							border_size = 5,
							T.button {
								id = "ok",
								label = _ "Select"
							}
						},
						T.column {
							grow_factor = 0,
							border = "all",
							border_size = 5,
							T.button {
								id = "cancel",
								label = wgettext("Cancel")
							}
						}
					}
				}
			}
		}
	}
}

local function horizontal_choice_ui(options, title, message, contextual)
	local current_choice = 0

	local function preshow(self)
		if contextual then
			self.ok.visible = false
			self.cancel.visible = false
			self.title.visible = false
		else
			self.title_small.visible = false
			self.cancel_small.visible = false
		end

		if title ~= nil then
			self.title.marked_up_text = title
			self.title_small.marked_up_text = title
		else
			self.title.visible = false
			self.title_small.visible = false
		end

		if message ~= nil then
			self.message.marked_up_text = message
		else
			self.message.visible = false
		end

		for i, opt in ipairs(options) do
			local item = self.option_list:add_item()

			if opt.icon ~= nil then
				item.icon.label = opt.icon
			end

			if opt.label ~= nil then
				item.label.marked_up_text = opt.label
			end

			if opt.description ~= nil then
				item.description.marked_up_text = opt.description
			else
				item.description.visible = false
			end

			if opt.default then
				self.option_list.selected_index = i
			end
		end

		self.option_list:focus()
		self.option_list.on_modified = function()
			current_choice = self.option_list.selected_index
			if contextual then
				self:close()
			end
		end

		self.cancel_small.on_button_click = function()
			current_choice = 0
			self:close()
		end
	end

	-- Note that these persist because we modify the original copy of the
	-- table (making a new copy each time would be annoying)
	if contextual then
		choice_dlg.automatic_placement = false
		choice_dlg.x = "(min(max(0, mouse_x - window_width / 2), screen_width - window_width))"
		choice_dlg.y = "(min(max(0, mouse_y - 22), screen_height - window_height))"
		choice_dlg.width = "(if(window_width > 0, window_width, screen_width))"
		choice_dlg.height = "(if(window_height > 0, window_height, screen_height))"
		choice_dlg.definition = "menu"
	else
		choice_dlg.automatic_placement = true
		choice_dlg.x = nil
		choice_dlg.y = nil
		choice_dlg.width = nil
		choice_dlg.height = nil
		choice_dlg.definition = nil
	end

	if gui.show_dialog(choice_dlg, preshow) == -2 then
		-- Dialog was cancelled via mouse or keyboard
		return 0
	end

	return current_choice
end

--[[
Pure Lua version of the [horizontal_choice] callback. This is provided as a
public function as a convenience for code that may need to invoke it directly
so as to avoid the creation of an intermediate WML document with the necessary
configuration options.

<b>NOTE:</b> Unlike the WML version, the result of this function is 1-based
instead of 0-based.
]]--
function synced_horizontal_choice(options, title, message, contextual)
	local synced = wesnoth.sync.evaluate_single(function()
		return { result = horizontal_choice_ui(options, title, message, contextual) }
	end)

	return math.max(synced.result, 0)
end

--[[
[horizontal_choice]
	# Name of a WML variable that should receive the choice number value
	# (0-based)
	variable="..."
	# Dialog caption
	title= _ "..."
	# Dialog message under the caption
	message= _ "..."
	# If enabled, this makes the dialog behave as though invoked from a
	# context menu, which removes the action buttons and makes a change in the
	# selection immediately confirm the dialog
	contextual=false

	# [option] tags are used to define each choice.
	[option]
		# Icon for the choice entry.
		icon="..."

		# Option label shown under the image.
		label= _ "..."

		# Fuller text to display under the option.
		description= _ "..."

		# Whether the option should be the default selection.
		default=no
	[/option]
[/horizontal_choice]
]]
function wesnoth.wml_actions.horizontal_choice(cfg)
	local variable = cfg.variable or wml.error("[horizontal_choice]: Must specify a variable=")

	local options = {}

	for opt_cfg in wml.child_range(cfg, "option") do
		table.insert(options, {
			icon        = opt_cfg.icon,
			label       = opt_cfg.label,
			description = opt_cfg.description,
			default     = opt_cfg.default,
		})
	end

	if #options < 1 then
		wml.error("[horizontal_choice]: At least one [option] is required")
	end

	-- This will set the WML variable to -1 if nothing was selected/the dialog
	-- was dismissed. This is intentional.
	wml.variables[variable] = synced_horizontal_choice(options, cfg.title, cfg.message, contextual)
end
