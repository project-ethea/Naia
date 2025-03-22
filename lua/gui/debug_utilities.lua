--
-- [debug_utilities] dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2024 - 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local BLANK_ICON = "misc/blank-hex.png~CROP(0,0,18,18)"

local DEBUG_ICON = "icons/action/editor-tool-item_25.png"

local UNIT_ICON = "icons/action/editor-tool-unit_25.png"

local HEX_ICON = "icons/action/minimap-draw-terrain_25.png"

local CONSOLE_ICON = "icons/menu-console.png"

local function debug_message(text)
	wesnoth.interface.add_chat_message("Naia [Debug]", text)
end

-- Filled in by scenarios via [register_debug_trigger]
local debug_triggers = {}

-- These are formally defined later
local debug_ui = {
	side_selector = function(message) end,
	location_selector = function(messge) end,
}

local UNIT_DEBUG_MENU = {
	{
		label = _ "debug^Restore HP",
		_action = function(x, y, unit)
			unit.hitpoints = unit.max_hitpoints
			debug_message(("Unit '%s' hitpoints reset to max"):format(unit.id))
		end
	},
	{
		label = _ "debug^Supercharge HP",
		_action = function(x, y, unit)
			unit.hitpoints = math.min(10 * unit.max_hitpoints, 1000)
			debug_message(("Unit '%s' hitpoints supercharged"):format(unit.id))
		end
	},
	{
		label = _ "debug^Set HP to 1",
		_action = function(x, y, unit)
			unit.hitpoints = 1
			debug_message(("Unit '%s' hitpoints set to 1"):format(unit.id))
		end
	},
	{
		label = _ "debug^Clear Status Effects",
		_action = function(x, y, unit)
			wesnoth.wml_actions.heal_unit {
				id = unit.id,
				restore_statuses = true
			}
			debug_message(("Unit '%s' statuses cleared"):format(unit.id))
		end
	},
	{
		label = _ "debug^Restore Moves/Attacks",
		_action = function(x, y, unit)
			unit.moves = unit.max_moves
			unit.attacks_left = unit.max_attacks
			debug_message(("Unit '%s' moves/attacks reset to max"):format(unit.id))
		end
	},
	{
		label = _ "debug^Supercharge Moves/Attacks",
		_action = function(x, y, unit)
			unit.moves = 10
			unit.attacks_left = 10
			debug_message(("Unit '%s' moves/attacks supercharged"):format(unit.id))
		end
	},
	{
		label = _ "debug^Advance",
		_action = function(x, y, unit)
			local old_type = unit.type
			unit.experience = unit.max_experience
			unit:advance(true, true)
			debug_message(("Unit '%s' ('%s') advanced to '%s'"):format(unit.id, old_type, unit.type))
		end
	},
	{
		label = _ "debug^Transfer to Side",
		_action = function(x, y, unit)
			local side = debug_ui.side_selector(tostring( _ "debug^Select a side for this unit:"):format(x, y))
			if side > 1 then
				unit.side = side
				debug_message(("Unit '%s' transferred to side %d"):format(unit.id, side))
			end
		end
	},
	{
		label = _ "debug^Face Direction",
		_action = function(x, y, unit)
			local direction = {
				{
					icon = UNIT_ICON,
					label = _ "debug^Northwest",
					_value = "nw"
				},
				{
					icon = UNIT_ICON,
					label = _ "debug^North",
					_value = "n"
				},
				{
					icon = UNIT_ICON,
					label = _ "debug^Northeast",
					_value = "ne"
				},
				{
					icon = UNIT_ICON,
					label = _ "debug^Southeast",
					_value = "se"
				},
				{
					icon = UNIT_ICON,
					label = _ "debug^South",
					_value = "s"
				},
				{
					icon = UNIT_ICON,
					label = _ "debug^Southwest",
					_value = "sw"
				}
			}

			local result = gui.show_menu(direction)

			if result > 0 then
				local facing = direction[result]._value
				unit.facing = facing
				unit:extract()
				unit:to_map()
				debug_message(("Unit '%s' facing set to %s"):format(unit.id, facing))
			end
		end
	},
	{
		label = _ "debug^Teleport",
		_action = function(x, y, unit)
			local location = debug_ui.location_selector({ x = x, y = y })
			if location and not (location.x == x and location.y == y) then
				unit:teleport(location.x, location.y, true, true, false)
				debug_message(("Unit '%s' teleported to %d, %d"):format(unit.id, location.x, location.y))
			end
		end
	}
}

local TERRAIN_DEBUG_MENU = {
	{
		label = _ "debug^Capture Village",
		_action = function(x, y)
			local side = wesnoth.current.side
			wesnoth.current.map.set_owner(x, y, side)
			debug_message(("Captured village at %d, %d by side %d"):format(x, y, side))
		end
	},
	{
		label = _ "debug^Uncapture Village",
		_action = function(x, y)
			wesnoth.current.map.set_owner(x, y, 0)
			debug_message(("Uncaptured village at %d, %d"):format(x, y))
		end
	},
	{
		label = _ "debug^Give Village to Side",
		_action = function(x, y)
			local side = debug_ui.side_selector()
			if side then
				wesnoth.current.map.set_owner(x, y, side)
				debug_message(("Captured village at %d, %d by side %d"):format(x, y, side))
			end
		end
	},
	{
		label = _ "debug^Clear Overlay",
		_action = function(x, y)
			wesnoth.wml_actions.remove_terrain_overlays { x = x, y = y }
			debug_message(("Cleared terrain overlay at %d, %d"):format(x, y))
		end
	}
}

function wesnoth.wml_conditionals.debug_utilities_available()
	return wesnoth.game_config.debug and naia_is_in_maintainer_mode()
end

function wesnoth.wml_conditionals.debug_location_on_map()
	local x, y = wesnoth.interface.get_hovered_hex()
	return wesnoth.current.map:on_board(x, y, false)
end

function wesnoth.wml_conditionals.debug_triggers_available()
	return #debug_triggers > 0
end

function wesnoth.wml_actions.register_debug_trigger(cfg)
	debug_triggers = {}
	local i = 1
	for trigger in wml.child_range(cfg, "trigger") do
		debug_triggers[i] = {
			event_name = trigger.event_name,
			label = trigger.label
		}
		wprintf(W_DBG, "[register_debug_trigger] Event '%s' registered", trigger.event_name)
		i = i + 1
	end
end

function wesnoth.wml_actions.unit_debug_utilities()
	local x = wesnoth.current.event_context.unit_x
	local y = wesnoth.current.event_context.unit_y
	local u = wesnoth.units.get(x, y)

	if not u then
		wprintf(W_ERR, "BUG: [unit_debug_utilities] invoked without a unit under the cursor")
		return
	end

	local menu = {}
	for i = 1, #UNIT_DEBUG_MENU do
		menu[i] = {
			icon = UNIT_DEBUG_MENU[i].icon or UNIT_ICON,
			label = UNIT_DEBUG_MENU[i].label
		}
	end

	local result = gui.show_menu(menu)

	if result > 0 then
		UNIT_DEBUG_MENU[result]._action(x, y, u)
		wesnoth.wml_actions.redraw {}
	end
end

function wesnoth.wml_actions.terrain_debug_utilities()
	local x, y = wesnoth.interface.get_hovered_hex()

	local menu = {}
	for i = 1, #TERRAIN_DEBUG_MENU do
		menu[i] = {
			icon = TERRAIN_DEBUG_MENU[i].icon or HEX_ICON,
			label = TERRAIN_DEBUG_MENU[i].label
		}
	end

	local result = gui.show_menu(menu)

	if result > 0 then
		TERRAIN_DEBUG_MENU[result]._action(x, y)
		wesnoth.wml_actions.redraw {}
	end
end

function wesnoth.wml_actions.event_debug_utilities()
	local menu = {}
	for i = 1, #debug_triggers do
		local trigger_label = tostring( _ "debug^Trigger: %s"):format(debug_triggers[i].label)
		menu[i] = {
			icon = DEBUG_ICON,
			label = trigger_label
		}
	end

	local result = gui.show_menu(menu)

	if result > 0 then
		wesnoth.game_events.fire(debug_triggers[result].event_name)
	end
end

local function side_selector_column(id)
	return T.column {
		border = "all",
		border_size = 5,
		horizontal_grow = true,
		T.label {
			id = id,
			linked_group = id
		}
	}
end

local side_selector_listdef = {
	T.row {
		T.column {
			vertical_grow = true,
			horizontal_grow = true,
			T.toggle_panel {
				definition = "default",
				T.grid {
					T.row {
						side_selector_column("side_number"),

						side_selector_column("id"),

						side_selector_column("team_name")
					}
				}
			}
		}
	}
}

local function tool_settings_dlg(cfg)
	return wml.merge(cfg, {
		definition = "menu",

		automatic_placement = false,
		x = "(min(max(0, mouse_x - window_width / 2), screen_width - window_width))",
		y = "(min(max(0, mouse_y - 22), screen_height - window_height))",
		width = "(if(window_width > 0, window_width, screen_width))",
		height = "(if(window_height > 0, window_height, screen_height))",
		maximum_width = 640,
		maximum_height = 400,

		T.helptip { id = "tooltip" },
		T.tooltip { id = "tooltip" }
	}, "merge")
end

local side_selector_dlg = tool_settings_dlg {
	T.linked_group { id = "side_number", fixed_width = true },
	T.linked_group { id = "id", fixed_width = true },
	T.linked_group { id = "team_name", fixed_width = true },

	T.grid {
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_grow = true,
				T.grid {
					T.row {
						T.column {
							grow_factor = 1,
							border = "top,left,right",
							border_size = 5,
							horizontal_alignment = "left",
							T.label {
								definition = "gold",
								label = _ "debug^Select Side",
								wrap = true
							}
						},
						T.column {
							grow_factor = 0,
							border = "top,left",
							border_size = 5,
							horizontal_alignment = "right",
							T.button {
								id = "ok",
								definition = "naia_mini_ok",
								label = wgettext("Select")
							}
						},
						T.column {
							grow_factor = 0,
							border = "top,left,right",
							border_size = 5,
							horizontal_alignment = "right",
							T.button {
								id = "cancel",
								definition = "naia_mini_close",
								label = wgettext("Cancel")
							}
						}
					}
				}
			}
		},
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				horizontal_grow = true,
				T.listbox {
					id = "side_list",
					definition = "default",
					T.list_definition(side_selector_listdef)
				}
			}
		}
	}
}

local location_selector_dlg = tool_settings_dlg {
	T.grid {
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_grow = true,
				T.grid {
					T.row {
						T.column {
							grow_factor = 1,
							border = "top,left,right",
							border_size = 5,
							horizontal_alignment = "left",
							T.label {
								definition = "gold",
								label = _ "debug^Enter Location",
								wrap = true
							}
						},
						T.column {
							grow_factor = 0,
							border = "top,left",
							border_size = 5,
							horizontal_alignment = "right",
							T.button {
								id = "ok",
								definition = "naia_mini_ok",
								label = wgettext("OK")
							}
						},
						T.column {
							grow_factor = 0,
							border = "top,left,right",
							border_size = 5,
							horizontal_alignment = "right",
							T.button {
								id = "cancel",
								definition = "naia_mini_close",
								label = wgettext("Cancel")
							}
						}
					}
				}
			}
		},
		T.row {
			T.column {
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							T.label {
								label = "X:"
							}
						},
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = false,
							T.text_box {
								id = "location_x"
							}
						},
					},
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							T.label {
								label = "Y:"
							}
						},
						T.column {
							border = "all",
							border_size = 5,
							horizontal_grow = false,
							T.text_box {
								id = "location_y"
							}
						}
					}
				}
			}
		}
	}
}

---
-- Side selection UI
---

function debug_ui.side_selector()
	local selection = 1

	local function preshow(self)
		for side, num in wesnoth.sides.iter() do
			local row = self.side_list:add_item()
			row.side_number.label = tostring(num)
			row.id.label = side.save_id
			row.team_name.marked_up_text = ("%s (<tt>%s</tt>)"):format(side.user_team_name, side.team_name)
		end

		self.side_list:focus()
	end

	local function postshow(self)
		selection = self.side_list.selected_index
	end

	return wesnoth.sync.evaluate_single(function()
		local result = 0
		if gui.show_dialog(side_selector_dlg, preshow, postshow) == -1 then
			result = selection
		end
		return { result = result }
	end).result
end

---
-- Location selection UI
---

function debug_ui.location_selector(initial_loc)
	local loc = { x = -1, y = -1 }

	local function preshow(self)
		self.location_x.text = initial_loc.x
		self.location_y.text = initial_loc.y
	end

	local function postshow(self)
		loc.x = self.location_x.text
		loc.y = self.location_y.text
	end

	loc = wesnoth.sync.evaluate_single(function()
		if gui.show_dialog(location_selector_dlg, preshow, postshow) == -1 and wesnoth.current.map:on_board(loc.x, loc.y, false) then
			return { x = loc.x, y = loc.y }
		else
			return { x = -1, y = -1 }
		end
	end)

	if loc.x < 1 or loc.y < 1 then
		return nil
	else
		return loc
	end
end

---
-- Create WML context menu items
---

wesnoth.wml_actions.set_menu_item {
	id = "naia:90_1_debug_unit",
	description = _ "debug^Naia: Unit Debug Utilities",
	image = UNIT_ICON,
	T.show_if {
		T.debug_utilities_available {}
	},
	T.filter_location {
		T.filter {}
	},
	T.command {
		T.unit_debug_utilities {}
	}
}

wesnoth.wml_actions.set_menu_item {
	id = "naia:90_2_debug_terrain",
	description = _ "debug^Naia: Terrain Debug Utilities",
	image = HEX_ICON,
	T.show_if {
		T.debug_utilities_available {},
		T.debug_location_on_map {}
	},
	T.command {
		T.terrain_debug_utilities {}
	}
}

wesnoth.wml_actions.set_menu_item {
	id = "naia:90_3_debug_events",
	description = _ "debug^Naia: Debug Events",
	image = DEBUG_ICON,
	T.show_if {
		T.debug_utilities_available {},
		T.debug_triggers_available {}
	},
	T.command {
		T.event_debug_utilities {}
	}
}

wesnoth.wml_actions.set_menu_item {
	id = "naia:90_9_console",
	description= _ "debug^Naia: Lua Console",
	image = CONSOLE_ICON,
	T.show_if {
		T.debug_utilities_available {}
	},
	T.command {
		T.lua {
			code = "gui.show_lua_console()"
		}
	}
}
