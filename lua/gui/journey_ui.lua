--
-- Wesnoth Journey Log module (front-end)
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2024 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

-- WARNING: enabling this exposes incomplete, untested or crash-prone
--          functionality!
local JOURNEYLOG_ALLOW_BROKEN_GARBAGE      = false

local JOURNEYLOG_UI_PORTRAIT_SIZE          = 128
local JOURNEYLOG_UI_SCENARIO_ICON          = "help/closed_section.png"
local JOURNEYLOG_UI_SCENARIO_ICON_SELECTED = "help/open_section.png"

local EVENT_LABELS = {
	start       = _ "event^Preparing for combat",
	time_over   = _ "event^Combat over",

	attack      = _ "event^Confrontation",
	moveto      = _ "event^Location approached",

	last_breath = _ "event^Character’s last words",
	die         = _ "event^Character death",

	defeat      = _ "event^Defeat",
	victory     = _ "event^Victory",
}

gui.add_widget_definition("window", "naia_journeylog", {
	id = "naia_journeylog",
	description = "a decade and a half later, gui2 still sucks",

	T.resolution {
		-- Mystery magic numbers from _GUI_RESOLUTION_BORDERLESS_BASE, found
		-- in data/gui/widget/window_borderless.cfg on Wesnoth 1.18.
		left_border = 10,
		right_border = 13,
		top_border = 10,
		bottom_border = 13,

		T.background {
			T.draw {
				T.pre_commit {
					T.blur {
						depth = 8
					}
				},
				T.image {
					x = 0,
					y = 0,
					w = "(width)",
					h = "(height)",
					-- Brighten it up a bit
					name = "dialogs/translucent65-background.png~CS(20,22,26)",
					resize_mode = "tile_highres"
				},
				T.image {
					x = 0,
					y = 0,
					w = "(width)",
					h = "(height * 0.66)",
					name = "misc/journeylog-bg.png",
					resize_mode = "stretch"
				}
			}
		},
		T.foreground {
			T.draw {}
		},
		T.grid {
			T.row {
				grow_factor = 1,
				T.column {
					horizontal_grow = false, -- !!!
					vertical_grow = true,
					T.scrollbar_panel {
						vertical_scrollbar_mode = "initial_auto",
						horizontal_scrollbar_mode = "initial_auto",
						T.definition {
							T.row {
								T.column {
									horizontal_grow = true,
									vertical_grow = true,
									T.grid {
										id = "_window_content_grid"
									}
								}
							}
						}
					}
				}
			},
			T.row {
				T.column {
					T.button {
						id = "click_dismiss",
						definition = "default",
						label = wgettext("Close", "wesnoth-lib")
					}
				}
			}
		}
	}
})

local journeylog_section_listdef = {
	T.row {
		T.column {
			T.toggle_panel {
				T.grid {
					T.row {
						T.column {
							T.spacer {
								width = 20,
								height = 10
							}
						},
						T.column {
							grow_factor = 1,
							border = "all",
							border_size = 5,
							T.label {
								id = "tab_label",
								wrap = true
							}
						},
						T.column {
							T.spacer {
								width = 20,
								height = 10
							}
						}
					}
				}
			}
		}
	}
}

local journeylog_section_listdata = {
	T.row {
		T.column {
			T.widget {
				id = "tab_label",
				label = _ "Log"
			}
		}
	},
	T.row {
		T.column {
			T.widget {
				id = "tab_label",
				label = _ "Notes"
			}
		}
	}
}

local journeylog_scenarios_listdef = {
	-- TITLE
	T.row { T.column {
		vertical_grow = true,
		horizontal_grow = true,
		T.toggle_panel {
			definition = "fancy",
			linked_group = "scenario_name_group",
			T.grid {
				T.row {
					T.column {
						border = "top,left,bottom",
						border_size = 10,
						T.image {
							id = "scenario_icon"
						}
					},
					T.column {
						horizontal_grow = true,
						grow_factor = 1,
						border = "all",
						border_size = 10,
						T.label {
							id = "scenario_name"
						}
					}
				}
			}
		}
	}}
}

local journeylog_chara_img_display = { T.grid { T.row {
	T.column {
		horizontal_alignment = "right",
		vertical_alignment = "top",
		border = "all",
		border_size = 5,
		T.drawing {
			id = "image",
			width = JOURNEYLOG_UI_PORTRAIT_SIZE,
			height = JOURNEYLOG_UI_PORTRAIT_SIZE,
			linked_group = "portrait_img_group",
			T.draw {
				T.rectangle {
					w = "(width)",
					h = "(height)",
					border_thickness = 1,
					border_color = "114, 79, 46, 127",
					fill_color = "0, 0, 0, 127"
				},
				T.image {
					name = "(text)",
					x = "(if(image_original_width < width, (width - image_original_width)/2, 0))",
					y = "(if(image_original_width < height, (height - image_original_height)/2, 0))",
					-- BIG TODO: scale images proportionally if they don't fit
					w = "(min(image_original_width, width) * image_original_width/image_original_height)",
					h = "(min(image_original_height, height))",
					resize_mode = "scale_sharp"
				}
			}
		}
	},
	T.column {
		border = "right",
		border_size = 10,
		T.spacer {}
	}
}}}

local journeylog_chara_name_display = {
	horizontal_alignment = "left",
	border = "all",
	border_size = 5,
	T.label {
		id = "chara_name",
		definition = "gold_large",
		linked_group = "message_text_group",
		wrap = true
	}
}

local journeylog_chara_msg_display = {
	horizontal_alignment = "left",
	border = "all",
	border_size = 5,
	T.label {
		id = "chara_msg",
		linked_group = "message_text_group",
		characters_per_line = 66,
		wrap = true
	}
}

local journeylog_user_msg_display = {
	horizontal_alignment = "left",
	border = "all",
	border_size = 5,
	T.label {
		id = "user_msg",
		definition = "gold",
		linked_group = "message_text_group",
		wrap = true
	}
}

local journeylog_msg_spacer_col = {
	border = "top",
	border_size = 10,
	T.spacer {}
}

local journeylog_messages_treedef = {
	id = "messages_tree",
	horizontal_scrollbar_mode = "never",
	vertical_scrollbar_mode = "always",
	indentation_step_size = 0,
	T.node {
		id = "container",
		unfolded = true,
		T.node_definition {
			T.row {
				T.column {
					T.spacer {
					}
				}
			}
		}
	},

	T.node {
		id = "plain_message",
		T.node_definition {
			T.row {
				T.column {
					T.grid {
						T.row {
							T.column(journeylog_chara_img_display),
							T.column {
								horizontal_grow = true,
								vertical_alignment = "top",
								T.grid {
									T.row {
										T.column(journeylog_chara_name_display)
									},
									T.row {
										T.column(journeylog_chara_msg_display)
									}
								}
							}
						}
					}
				}
			},
			T.row {
				T.column(journeylog_msg_spacer_col)
			}
		}
	},

	T.node {
		id = "message_with_input",
		T.node_definition {
			T.row {
				T.column {
					T.grid {
						T.row {
							T.column(journeylog_chara_img_display),
							T.column {
								horizontal_grow = true,
								vertical_alignment = "top",
								T.grid {
									T.row {
										T.column(journeylog_chara_name_display)
									},
									T.row {
										T.column(journeylog_chara_msg_display)
									},
									T.row {
										T.column(journeylog_user_msg_display)
									}
								}
							}
						}
					}
				}
			},
			T.row {
				T.column(journeylog_msg_spacer_col)
			}
		}
	},

	T.node {
		id = "message_block_separator",
		T.node_definition {
			T.row {
				T.column {
					horizontal_alignment = "center",
					T.image {
						label = "dialogs/multi_create/decor.png"
					}
				}
			}
		}
	},

	T.node {
		id = "widget_metrics_hack",
		T.node_definition {
			T.row {
				T.column {
					horizontal_alignment = "right",
					vertical_alignment = "top",
					border = "all",
					border_size = 5,
					T.drawing {
						linked_group = "portrait_img_group",
						-- Dummy [draw] to avoid CTD on 1.18.2 and earlier
						-- <https://github.com/wesnoth/wesnoth/issues/9214>
						T.draw {
							T.rectangle {
								x = 0,
								y = 0,
								w = 1,
								h = 1
							}
						}
					}
				},
				T.column(journeylog_chara_msg_display)
			}
		}
	}
}

local journeylog_main_grid = {
	T.row {
		T.column {
			grow_factor = 1,
			horizontal_grow = true,
			vertical_alignment = "top",
			border = "all",
			border_size = 5,
			T.listbox {
				id = "scenario_list",
				T.list_definition(journeylog_scenarios_listdef)
			}
		},
		T.column {
			grow_factor = 3,
			horizontal_alignment = "left",
			vertical_grow = true,
			border = "all",
			border_size = 5,
			T.tree_view(journeylog_messages_treedef)
		}
	}
}

local journeylog_dlg = {
	definition = "naia_journeylog",

	automatic_placement = false,
	x = 0,
	y = 0,
	width = "(screen_width)",
	height = "(screen_height)",

	T.helptip { id = "tooltip" },
	T.tooltip { id = "tooltip" },

	T.linked_group {
		id = "scenario_name_group",
		fixed_width = true
	},

	T.linked_group {
		id = "portrait_img_group",
		fixed_width = true
	},

	T.linked_group {
		id = "message_text_group",
		fixed_width = true
	},

	T.grid {
		T.row {
			T.column {
				horizontal_grow = true,
				vertical_alignment = "top",
				T.stacked_widget {
					T.layer {
						T.row {
							T.column {
								horizontal_alignment = "center",
								border = "top,left,right",
								border_size = 5,
								T.label {
									definition = "title",
									label = _ "Journey Log"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "center",
								border = "all",
								border_size = 5,
								T.image {
									label = "misc/loadscreen_decor.png~BLEND(162, 127, 68, 1.0)"
								}
							}
						}
					},
					T.layer {
						T.row {
							T.column {
								horizontal_alignment = "left",
								T.grid {
									T.row {
										T.column {
											border = "all",
											border_size = 5,
											T.horizontal_listbox {
												id = "log_section_selector",
												T.list_definition(journeylog_section_listdef),
												T.list_data(journeylog_section_listdata)
											}
										}
									}
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.text_box {
									id = "search_box",
									hint_text = _ "Search",
									hint_image = "icons/action/zoomdefault_25.png~FL(horiz)"
								}
							}
						}
					}
				}
			}
		},
		T.row {
			T.column {
				horizontal_alignment = "center",
				vertical_grow = true,
				T.grid(journeylog_main_grid)
			}
		},
		T.row {
			T.column {
				horizontal_grow = true,
				vertical_alignment = "bottom",
				border = "top",
				border_size = 5,
				T.grid {
					T.row {
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.button {
								id = "campaigns_menu",
								label = _ "<unknown campaign>",
								tooltip = _ "Select the campaign to display",
								linked_group = "scenario_name_group"
							}
						},
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.button {
								id = "ok",
								label = wgettext("Close")
							}
						}
					}
				}
			}
		}
	}
}

local function jprintf(lvl, msg, ...)
	wprintf(lvl, "JourneyLogUI: " .. msg, ...)
end

local function clean_campaign_name(text)
	return tostring(text):gsub("\n", " ")
end

function journeylog_run_ui()
	local journeylog = {}
	local current_campaign, current_scenario = 0, 0
	-- These are collections of current container item refs for easier
	-- mass-manipulation (e.g. for filtering).
	local scenario_listbox_rows = {}
	-- For each entry, .message is a ref to the original journeylog message
	-- while .ui is a ref to the treeview node.
	local journey_view_rows = {}

	local function clear_journey_view(treeview)
		journey_view_rows = {}
		treeview:remove_items_at(1, 0)
	end

	local function journey_view_add_node(treeview, node_type, journey_msg)
		local container = treeview:add_item_of_type("container")
		local new_node = container:add_item_of_type(node_type)
		table.insert(journey_view_rows, {
			message = journey_msg,
			ui = new_node,
			parent = container,
			visible = function() return container.unfolded end,
			set_visible = function(value) container.unfolded = value end
		})
		return new_node
	end

	local function show_journey(self, campaign_num, scenario_num)
		if not campaign_num then
			-- TODO: display UI placeholder
			return
		end

		if campaign_num > #journeylog then
			jprintf(W_ERR, "show_journey() campaign number out of bounds: %d > %d",
					campaign_num, #journeylog)
			return
		end

		if not scenario_num then
			scenario_num = #journeylog[campaign_num].scenarios
		end

		if scenario_num > #journeylog[campaign_num].scenarios then
			jprintf(W_ERR, "show_journey() scenario number out of bounds: %d > %d",
					scenario_num, #journeylog[campaign_num].scenarios)
			return
		end

		current_scenario = scenario_num

		local campaign_id = journeylog[campaign_num].id
		local journey = journeylog[campaign_num].scenarios[scenario_num]
		local scenario_id = journey.id

		if not journey.cache_built then
			-- Didn't cache this journey yet...
			local raw_journey = journeylog_read_scenario(campaign_id, scenario_id)

			for i, msg_block in ipairs(raw_journey) do
				if i > 1 then
					table.insert(journey.messages, { is_separator = true })
				end

				for j, msg in ipairs(msg_block) do
					-- We don't do anything fancy with messages yet
					table.insert(journey.messages, msg)
				end
			end

			journey.cache_built = true
		end

		-- Cache built, we can proceed with the UI display now

		local treeview = self.messages_tree
		clear_journey_view(treeview)

		for i, msg in ipairs(journey.messages) do
			if msg.is_separator then
				journey_view_add_node(treeview, "message_block_separator")
			else
				local msg_display

				if msg.choice == nil then
					msg_display = journey_view_add_node(treeview, "plain_message", msg)
				else
					msg_display = journey_view_add_node(treeview, "message_with_input", msg)
				end

				if msg.image ~= nil then
					msg_display.image.label = msg.image
				else
					msg_display.image.visible = "hidden"
				end

				if not msg.is_narrator and msg.speaker ~= nil then
					msg_display.chara_name.marked_up_text = msg.speaker
				else
					msg_display.chara_name.visible = "hidden"
				end

				if msg.message ~= nil then
					msg_display.chara_msg.marked_up_text = msg.message
				end
			end
		end

		-- HACK: Add a hidden item at the end to enforce the maximum width for
		--       the treeview regardless of message contents. This is unmanaged
		--       on purpose since we have no need for tinkering with it later.
		local metrics_hack = treeview:add_item_of_type("widget_metrics_hack")
		metrics_hack.chara_msg.label = ("PADDING"):rep(12)
		metrics_hack.chara_msg.visible = "hidden"
	end

	local function set_journey_filter(self, search_terms)
		local clean_terms = search_terms or ""
		-- Trim leading and trailing whitespace
		clean_terms = clean_terms:trim()

		if #clean_terms == 0 then
			for i, row in ipairs(journey_view_rows) do
				row.set_visible(true)
			end
			return
		end

		local words = {}
		for word in search_terms:gmatch("[^%s]+") do
			table.insert(words, word:lower())
		end

		for i, row in ipairs(journey_view_rows) do
			if row.message then
				local contents = {
					row.message.speaker,
					row.message.message
				}

				local visible = false

				for j, tstring in pairs(contents) do
					if tstring then
						-- Unfortunately we need to deep-copy translatable strings
						-- in order to search through them...
						local sz = tostring(tstring):lower()
						for k, word in pairs(words) do
							--wprintf(W_DBG, "find '%s' in '%s'", word, sz)
							if sz:find(word, 1, true) then
								visible = true
								break
							end
						end

					end
				end

				row.set_visible(visible)
			end
		end
	end

	local function update_scenario_icon(self)
		if self.scenario_list.selected_index ~= current_scenario then
			scenario_listbox_rows[current_scenario].scenario_icon.label = JOURNEYLOG_UI_SCENARIO_ICON
		end

		scenario_listbox_rows[self.scenario_list.selected_index].scenario_icon.label = JOURNEYLOG_UI_SCENARIO_ICON_SELECTED
	end

	local function preshow(self)
		for i, campaign in ipairs(journeylog_enumerate_campaigns()) do
			if campaign.id == wesnoth.scenario.campaign.id then
				current_campaign = i
				self.campaigns_menu.label = clean_campaign_name(campaign.name)
			end

			local campaign_journey = {
				id = campaign.id,
				name = campaign.name,
				scenarios = {},
			}

			for j, scenario in ipairs(journeylog_enumerate_scenarios(campaign.id)) do
				jprintf(W_DBG, "enumerate scenario %s", scenario.id)
				if scenario.id == wesnoth.scenario.id then
					current_scenario = j
				end

				local scenario_journey = {
					id = scenario.id,
					name = scenario.name,
					messages = {},
					cache_built = false,
				}

				local scenario_list_item = self.scenario_list:add_item()
				scenario_list_item.scenario_name.label = scenario.name
				scenario_list_item.scenario_icon.label = JOURNEYLOG_UI_SCENARIO_ICON
				table.insert(scenario_listbox_rows, scenario_list_item)

				-- We do not retrieve messages until a later time because that
				-- will result in a lot of deep t_string copies in C++. Let the
				-- user trigger those on a per-scenario basis when selecting
				-- one in the interface, since most of the time they won't be
				-- walking through the entire campaign's dialogues anyway.

				table.insert(campaign_journey.scenarios, scenario_journey)
			end

			table.insert(journeylog, campaign_journey)
		end

		-- TODO: The campaigns menu causes the script to crash and also does
		-- not yet repopulate the scenario list.
		--self.campaigns_menu.enabled = #journeylog > 1

		-- HACK: Wesnoth 1.18 does not support runtime changes to the
		-- contents of [menu_button] in Lua, so we make do with
		-- gui.show_menu instead. Luckily, it should be pretty rare for
		-- this button to be visible and enabled in the first place, so we
		-- can tolerate the tackiness.
		self.campaigns_menu.on_button_click = function()
			local menu_table = {}
			for i, campaign in ipairs(journeylog) do
				table.insert(menu_table, {
					label = campaign.name
				})
			end

			local index = gui.show_menu(menu_table)
			if index > 0 then
				current_campaign = index
				self.campaigns_menu.label = clean_campaign_name(journeylog[index].name)
				show_journey(self, index, 0)
			end
		end

		self.scenario_list.selected_index = current_scenario
		self.scenario_list:focus()
		update_scenario_icon(self)

		self.scenario_list.on_modified = function()
			update_scenario_icon(self)
			show_journey(self, current_campaign, self.scenario_list.selected_index)
		end

		self.search_box.on_modified = function()
			set_journey_filter(self, self.search_box.text)
		end

		if not JOURNEYLOG_ALLOW_BROKEN_GARBAGE then
			self.campaigns_menu.visible = false
			self.log_section_selector.visible = false
		end

		-- Set the initial selection.
		show_journey(self, current_campaign, current_scenario)
	end

	gui.show_dialog(journeylog_dlg, preshow)
end

--
-- Displays the JourneyLog user interface.
--
-- Usage:
--
--   [journeylog]
--   [/journeylog]
--
function wesnoth.wml_actions.journeylog()
	-- [journeylog] does not modify the gamestate, so it does not require a
	-- synced context to run.
	wesnoth.sync.run_unsynced(function() journeylog_run_ui() end)
end

--
-- Create WML context menu items
--

wesnoth.wml_actions.set_menu_item {
	id = "naia:journeylog",
	description = _ "Journey Log",
	image = "icons/menu-journeylog.png",
	T.default_hotkey {
		key = "j",
	},
	T.command {
		T.journeylog {}
	}
}
