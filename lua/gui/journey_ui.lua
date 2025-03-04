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

local JOURNEYLOG_UI_ENTRY_TOP_MARGIN       = 10

local JOURNEYLOG_UI_SCENARIO_ICON          = "help/closed_section.png"
local JOURNEYLOG_UI_SCENARIO_ICON_SELECTED = "help/open_section.png"

local JOURNEYLOG_UI_MAJOR_DIVIDER          = "misc/loadscreen_decor.png~BLEND(162, 127, 68, 1.0)"
local JOURNEYLOG_UI_MINOR_DIVIDER          = "misc/ui-gradient.png~BLEND(162, 127, 68, 1.0)"

local JOURNEYLOG_UI_BIO_PLACEHOLDER        = _ "No information is presently available."
local JOURNEYLOG_UI_RACE_PLACEHOLDER       = _ "race^?"
local JOURNEYLOG_UI_STATUS_PLACEHOLDER     = _ "chara_status^Living"
local JOURNEYLOG_UI_GROUPS_PLACEHOLDER     = _ "affiliation^None"
local JOURNEYLOG_UI_TITLES_PLACEHOLDER     = _ "additional_titles^None"

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

local UI_TAB_LABELS = {
	_ "Journal",
	_ "Knowledge",
}

local BIO_STATUS_LABELS = {
	dead        = _ "chara_status^Deceased",
	missing     = _ "chara_status^Missing",
}

local ARCHIVE_MODE_CHARACTERS = 1
local ARCHIVE_MODE_WORLD      = 2

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
				label = UI_TAB_LABELS[1]
			}
		}
	},
	T.row {
		T.column {
			T.widget {
				id = "tab_label",
				label = UI_TAB_LABELS[2]
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

local journeylog_chara_img_display = {
	vertical_alignment = "top",
	T.grid {
		T.row {
			T.column {
				horizontal_alignment = "right",
				vertical_alignment = "top",
				border = "all",
				border_size = 5,
				T.button {
					id = "image",
					linked_group = "portrait_img_group",
					definition = "naia_journeylog_image_viewer_button_small"
				}
			},
			T.column {
				border = "right",
				border_size = 10,
				T.spacer {}
			}
		}
	}
}

local journeylog_chara_name_display_compact = {
	horizontal_alignment = "right",
	vertical_alignment = "top",
	grow_factor = 0,
	border = "all",
	border_size = 5,
	T.label {
		id = "chara_name",
		definition = "naia_journeylog_dialog_speaker_inline",
		linked_group = "portrait_img_group",
		text_alignment = "right",
		wrap = true
	}
}

local journeylog_chara_name_display = {
	horizontal_alignment = "left",
	border = "all",
	border_size = 5,
	T.label {
		id = "chara_name",
		definition = "naia_journeylog_dialog_speaker",
		linked_group = "message_text_group",
		wrap = true
	}
}

local journeylog_chara_msg_display = {
	grow_factor = 1,
	horizontal_alignment = "left",
	border = "all",
	border_size = 5,
	T.label {
		id = "chara_msg",
		definition = "naia_journeylog_dialog_line",
		linked_group = "message_text_group",
		wrap = true
	}
}

local journeylog_narrator_msg_display = {
	grow_factor = 1,
	horizontal_alignment = "right",
	border = "all",
	border_size = 5,
	T.label {
		id = "chara_msg",
		definition = "naia_journeylog_dialog_line",
		linked_group = "message_text_group",
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
	definition = "naia_journeylog_viewer",
	linked_group = "right_side_pane",
	horizontal_scrollbar_mode = "never",
	vertical_scrollbar_mode = "always",
	indentation_step_size = 0,

	T.node {
		id = "container",
		unfolded = true,
		T.node_definition {
			T.row {
				T.column {
					T.spacer {}
				}
			}
		}
	},

	T.node {
		id = "plain_message",
		T.node_definition {
			T.row {
				T.column {
					grow_factor = 1,
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
		id = "plain_message_compact",
		T.node_definition {
			T.row {
				T.column(journeylog_chara_name_display_compact),
				T.column(journeylog_chara_msg_display)
			},
			T.row {
				T.column(journeylog_msg_spacer_col),
				T.column(journeylog_msg_spacer_col)
			}
		}
	},

	T.node {
		id = "narrator_message",
		T.node_definition {
			T.row {
				T.column { T.spacer {} },
				T.column(journeylog_narrator_msg_display)
			},
			T.row {
				T.column(journeylog_msg_spacer_col),
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
		id = "message_with_input_compact",
		T.node_definition {
			T.row {
				T.column(journeylog_chara_name_display_compact),
				T.column {
					T.grid {
						T.row {
							T.column(journeylog_chara_msg_display)
						},
						T.row {
							T.column(journeylog_user_msg_display)
						}
					}
				}
			},
			T.row {
				T.column(journeylog_msg_spacer_col),
				T.column(journeylog_msg_spacer_col)
			}
		}
	},

	T.node {
		id = "message_block_separator",
		T.node_definition {
			T.row {
				T.column {
					grow_factor = 0,
					horizontal_alignment = "center",
					border = "bottom",
					border_size = 10,
					T.image {
						label = JOURNEYLOG_UI_MINOR_DIVIDER
					}
				}
			}
		}
	},

	T.node {
		id = "event_heading",
		T.node_definition {
			T.row {
				T.column {
					grow_factor = 0,
					horizontal_alignment = "center",
					border = "top",
					border_size = 5,
					T.label {
						id = "event",
						definition = "naia_journeylog_event_heading",
						text_alignment = "center"
					}
				}
			},
			T.row {
				T.column {
					grow_factor = 0,
					horizontal_alignment = "center",
					border = "bottom",
					border_size = 5,
					T.image {
						label = JOURNEYLOG_UI_MINOR_DIVIDER
					}
				}
			}
		}
	}
}

local journeylog_archive_listdef = {
	-- TITLE
	T.row { T.column {
		vertical_grow = true,
		horizontal_grow = true,
		T.toggle_panel {
			definition = "fancy",
			-- NOTE: piggybacking on the scenario list metrics on purpose!
			linked_group = "scenario_name_group",
			T.grid {
				T.row {
					T.column {
						horizontal_grow = true,
						grow_factor = 1,
						border = "all",
						border_size = 10,
						T.label {
							id = "archive_item_label"
						}
					}
				}
			}
		}
	}}
}

local function chara_info_panel_field(id, label)
	if id == nil or label == nil then
		return {
			T.column { T.spacer {} },
			T.column { T.spacer {} }
		}
	end

	return {
		T.column {
			grow_factor = 0,
			border = "all",
			border_size = 5,
			horizontal_grow = true,
			T.label {
				id = id .. "_heading",
				definition = "gold_small",
				-- TODO: crashes the game in 1.18 if the item is hidden
				--linked_group = "bio_info_group",
				label = tostring(label) .. ":",
				text_alignment = "right"
			}
		},
		T.column {
			grow_factor = 1,
			border = "all",
			border_size = 5,
			horizontal_grow = true,
			T.label {
				id = id,
				definition = "default_small",
				label = "BIO_PLACEHOLDER",
				text_alignment = "left"
			}
		}
	}
end

local journeylog_chara_info_panel = {
	T.row {
		T.column {
			grow_factor = 1,
			border = "top,bottom",
			border_size = 5,
			horizontal_grow = true,
			vertical_alignment = "top",
			T.grid {
				T.row(chara_info_panel_field("additional_titles", _ "Other titles")),
				T.row(chara_info_panel_field("affiliation",       _ "Affiliation")),
				T.row(chara_info_panel_field("status",            _ "Status")),
				T.row(chara_info_panel_field("race",              _ "Race")),
			}
		},
		T.column {
			grow_factor = 0,
			horizontal_alignment = "right",
			border = "all",
			border_size = 5,
			T.button {
				id = "chara_portrait",
				definition = "naia_journeylog_image_viewer_button"
			}
		}
	},
	T.row {
		T.column {
			T.spacer {
				height = JOURNEYLOG_UI_ENTRY_TOP_MARGIN
			}
		},
		T.column {
			T.spacer {}
		}
	}
}

local journeylog_archive_treedef = {
	id = "archive_entry",
	definition = "naia_journeylog_viewer",
	linked_group = "right_side_pane",
	horizontal_scrollbar_mode = "never",
	vertical_scrollbar_mode = "always",
	indentation_step_size = 0,

	T.node {
		id = "chara_profile",
		T.node_definition {
			T.row {
				T.column {
					horizontal_grow = true,
					T.grid {
						T.row {
							T.column {
								grow_factor = 1,
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "archive_entry_title",
									definition = "gold_large",
									label = "CHARA_NAME",
									wrap = true
								}
							},
							T.column {
								grow_factor = 0,
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.button {
									id = "unit_type_help",
									definition = "action_about",
									label = _ "Unit Description",
									tooltip = _ "Opens the character’s unit description in the Help browser"
								}
							}
						}
					}
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					T.grid(journeylog_chara_info_panel)
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.label {
						id = "archive_entry_body",
						definition = "naia_journeylog_page",
						label = "CHARA_DESCRIPTION",
						wrap = true
					}
				}
			}
		}
	},

	T.node {
		id = "lore_entry",
		T.node_definition {
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.label {
						id = "archive_entry_title",
						definition = "gold_large",
						label = "ENTRY_TITLE",
						wrap = true
					}
				}
			},
			T.row {
				T.column {
					T.spacer {
						height = JOURNEYLOG_UI_ENTRY_TOP_MARGIN
					}
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.label {
						id = "archive_entry_body",
						definition = "naia_journeylog_page",
						label = "ENTRY_TEXT",
						wrap = true
					}
				}
			}
		}
	}
}

local journeylog_dialoglog_grid = {
	T.row {
		grow_factor = 1,
		T.column {
			grow_factor = 1,
			horizontal_grow = true,
			vertical_alignment = "top",
			border = "all",
			border_size = 5,
			T.listbox {
				id = "scenario_list",
				linked_group = "left_side_pane",
				T.list_definition(journeylog_scenarios_listdef)
			}
		},
		T.column {
			grow_factor = 3,
			horizontal_alignment = "left",
			vertical_grow = true,
			border = "all",
			border_size = 5,
			T.panel {
				definition = "naia_journeylog_panel",
				T.grid {
					T.row {
						T.column {
							vertical_grow = true,
							border = "all",
							border_size = 5,
							T.tree_view(journeylog_messages_treedef)
						}
					}
				}
			}
		}
	}
}

local journeylog_archive_grid = {
	T.row {
		grow_factor = 1,
		T.column {
			grow_factor = 1,
			vertical_alignment = "top",
			T.grid {
				T.row {
					T.column {
						vertical_alignment = "top",
						border = "all",
						border_size = 5,
						T.menu_button {
							id = "archive_mode",
							linked_group = "left_side_pane",
							tooltip = _ "Select the type of items to display",
							T.option { label = _ "People"    },
							T.option { label = _ "The World" },
						}
					}
				},
				T.row {
					grow_factor = 1,
					T.column {
						horizontal_alignment = "left",
						vertical_alignment = "top",
						border = "all",
						border_size = 5,
						T.listbox {
							id = "archive_obj_list",
							linked_group = "left_side_pane",
							T.list_definition(journeylog_archive_listdef)
						}
					}
				}
			}
		},
		T.column {
			grow_factor = 3,
			horizontal_alignment = "left",
			vertical_grow = true,
			border = "all",
			border_size = 5,
			T.panel {
				definition = "naia_journeylog_panel",
				T.grid {
					T.row {
						grow_factor = 1,
						T.column {
							vertical_grow = true,
							border = "all",
							border_size = 5,
							T.tree_view(journeylog_archive_treedef)
						}
					}
				}
			}
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

	T.linked_group {
		id = "bio_info_group",
		fixed_width = true
	},

	T.linked_group {
		id = "left_side_pane",
		fixed_width = true
	},

	T.linked_group {
		id = "right_side_pane",
		fixed_width = true
	},

	T.grid {
		T.row {
			grow_factor = 0,
			T.column {
				grow_factor = 1,
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
									id = "title",
									definition = "title",
									label = "<DIALOG_TITLE>"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "center",
								border = "all",
								border_size = 5,
								T.image {
									label = JOURNEYLOG_UI_MAJOR_DIVIDER
								}
							}
						}
					},
					T.layer {
						T.row {
							T.column {
								horizontal_alignment = "left",
								vertical_alignment = "top",
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
								vertical_alignment = "top",
								border = "all",
								border_size = 5,
								T.text_box {
									id = "search_box",
									hint_text = _ "Search",
									hint_image = "icons/action/zoomdefault_25.png~FL(horiz)~CS(-80,-90,-100)"
								}
							}
						}
					}
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				horizontal_alignment = "center",
				vertical_grow = true,
				T.stacked_widget {
					id = "tabs_container",
					T.layer(journeylog_dialoglog_grid),
					T.layer(journeylog_archive_grid)
				}
			}
		},
		T.row {
			grow_factor = 0,
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
							grow_factor = 1,
							horizontal_alignment = "right",
							T.grid {
								T.row {
									grow_factor = 0,
									T.column {
										grow_factor = 0,
										horizontal_alignment = "right",
										border = "all",
										border_size = 5,
										T.toggle_button {
											id = "show_portraits",
											label = _ "Portraits",
										}
									},
									T.column {
										T.spacer {
											width = 30
										}
									},
									T.column {
										grow_factor = 0,
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
		}
	}
}

local image_viewer_dlg = {
	definition = "message",
	maximum_width = 800,
	maximum_height = 600,
	click_dismiss = true,

	automatic_placement = false,

	x = "(min(max(0, mouse_x - window_width / 2), screen_width - window_width))",
	y = "(min(max(0, mouse_y - window_height / 2), screen_height - window_height))",
	width = "(if(window_width > 0, window_width, screen_width))",
	height = "(if(window_height > 0, window_height, screen_height))",

	T.helptip { id = "tooltip" },
	T.tooltip { id = "tooltip" },

	T.grid {
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				T.image {
					id = "image"
				}
			}
		},
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				T.label {
					id = "caption",
					wrap = true,
					definition = "gold"
				}
			}
		}
	}
}

-- Helper to create closures to handle portrait click events.
local function portrait_image_viewer(image, caption)
	return function()
		gui.show_dialog(image_viewer_dlg, function(self)
			self.image.label = image .. "~BG(0,0,0)"
			self.caption.marked_up_text = caption or ""
			if caption == nil then
				self.caption.visible = false
			end
		end)
	end
end

local function jprintf(lvl, msg, ...)
	wprintf(lvl, "JourneyLogUI: " .. msg, ...)
end

local function clean_campaign_name(text)
	return tostring(text):gsub("\n", " ")
end

-- Helper to make markup text fancier by converting certain tags to use color
-- formatting.
local function transform_markup(markup)
	if markup then
		return tostring(markup):gsub("<b>([^<]+)</b>", "<span color='#baac7d'>%0</span>")
	else
		return nil
	end
end

local global_show_portraits = true

function journeylog_ui()
	local journal = {}
	local archive = {
		profiles = journeylog.retrieve_character_profiles(),
		world = journeylog.retrieve_world_lore(),
	}

	local archive_mode = ARCHIVE_MODE_CHARACTERS

	local current_campaign, current_scenario, current_page = 0, 0, 0
	-- These are collections of current container item refs for easier
	-- mass-manipulation (e.g. for filtering).
	local scenario_listbox_rows = {}
	-- For each entry, .message is a ref to the original journeylog message
	-- while .ui is a ref to the treeview node.
	local journey_view_rows = {}
	-- Content filter in use, as a list of words to match
	local current_filter = {}

	local function clear_journey_view(treeview)
		journey_view_rows = {}
		treeview:remove_items_at(1, 0)
	end

	local function journey_view_add_node(treeview, node_type, journey_msg)
		-- The dialog view uses an indirect approach where the treeview
		-- contains nodes that are in charge of containing the nodes with the
		-- true contents so that we can hide the latter by collapsing their
		-- parent nodes. This is essential since in 1.18, we cannot use the
		-- visible property on nodes without crashing the game.
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

	local function apply_journey_filter_row(row)
		if #current_filter == 0 then
			-- This is only relevant when this function is called during view
			-- rebuilds, because set_journey_filter() will manually bail and
			-- set all rows to visible if the filter is empty.
			return
		end

		if not row then
			-- Just syntactic sugar used when this is called during view
			-- rebuilds.
			row = journey_view_rows[#journey_view_rows]
			if not row then
				jprintf(W_ERR, "bad row")
				return
			end
		end

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
					for k, word in pairs(current_filter) do
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

		current_filter = {}
		for word in search_terms:gmatch("[^%s]+") do
			table.insert(current_filter, word:lower())
		end

		-- Reapply the journey filter after-the-fact without requiring a full
		-- rebuild of the current journey view, which would be more expensive.
		for i, row in ipairs(journey_view_rows) do
			apply_journey_filter_row(row)
		end
	end

	local function show_journey(self, campaign_num, scenario_num, force)
		if not campaign_num then
			-- TODO: display UI placeholder
			return
		end

		if not force and campaign_num == current_campaign and scenario_num == current_scenario then
			return
		end

		if campaign_num > #journal then
			jprintf(W_ERR, "show_journey() campaign number out of bounds: %d > %d",
					campaign_num, #journal)
			return
		end

		if not scenario_num then
			-- Presumably the last scenario on record is the scenario being
			-- played right now. (FIXME: maybe too optimistic an assumption?)
			scenario_num = #journal[campaign_num].scenarios
		end

		if scenario_num > #journal[campaign_num].scenarios then
			jprintf(W_ERR, "show_journey() scenario number out of bounds: %d > %d",
					scenario_num, #journal[campaign_num].scenarios)
			return
		end

		current_scenario = scenario_num

		local campaign_id = journal[campaign_num].id
		local journey = journal[campaign_num].scenarios[scenario_num]
		local scenario_id = journey.id

		if not journey.cache_built then
			-- Didn't cache this journey yet...
			local raw_journey = journeylog.read_scenario(campaign_id, scenario_id)

			for i, event_data in ipairs(raw_journey) do
				if i > 1 then
					table.insert(journey.messages, {
						event_name = event_data.event
					})
				end

				for j, msg in ipairs(event_data.messages) do
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
			if msg.event_name then
				local i18n_event_name = EVENT_LABELS[msg.event_name]

				if i18n_event_name then
					local event_heading = journey_view_add_node(treeview, "event_heading")
					event_heading.event.label = i18n_event_name
				else
					journey_view_add_node(treeview, "message_block_separator")
				end
			else
				local msg_display

				if global_show_portraits and not msg.is_narrator then
					if msg.choice == nil then
						msg_display = journey_view_add_node(treeview, "plain_message", msg)
					else
						msg_display = journey_view_add_node(treeview, "message_with_input", msg)
					end
				else
					if msg.is_narrator  then
						msg_display = journey_view_add_node(treeview, "narrator_message", msg)
					elseif msg.choice == nil then
						msg_display = journey_view_add_node(treeview, "plain_message_compact", msg)
					else
						msg_display = journey_view_add_node(treeview, "message_with_input_compact", msg)
					end
				end

				if global_show_portraits and not msg.is_narrator then
					if msg.image ~= nil then
						msg_display.image.label = msg.image
						msg_display.image.on_button_click = portrait_image_viewer(msg.image, msg.speaker)
					else
						msg_display.image.visible = "hidden"
					end
				end

				if not msg.is_narrator then
					if msg.speaker ~= nil then
						msg_display.chara_name.marked_up_text = msg.speaker
					else
						msg_display.chara_name.visible = "hidden"
					end
				end

				if msg.message ~= nil then
					if not msg.is_narrator then
						msg_display.chara_msg.marked_up_text = msg.message
					else
						msg_display.chara_msg.marked_up_text = ("<span color='#baac7d'>%s</span>"):format(msg.message)
					end
				end
			end

			apply_journey_filter_row()
		end
	end

	local function set_journey_portraits_shown(self, value)
		global_show_portraits = value
		show_journey(self, current_campaign, current_scenario, true)
	end

	local function update_scenario_icon(self)
		if self.scenario_list.selected_index ~= current_scenario then
			scenario_listbox_rows[current_scenario].scenario_icon.label = JOURNEYLOG_UI_SCENARIO_ICON
		end

		scenario_listbox_rows[self.scenario_list.selected_index].scenario_icon.label = JOURNEYLOG_UI_SCENARIO_ICON_SELECTED
	end

	local function bio_race_name_helper(race_id, gender_id)
		local gender = gender_id
		if not gender or gender == "unknown" then
			-- NOTE: Wesnoth 1.18 does not have a concept of an unknown gender
			gender = "male"
		end

		local race = wesnoth.races[race_id]

		if race then
			if gender == "female" then
				-- TODO: Wesnoth 1.18 does not offer female_name as a first-class
				--       citizen, why?
				return race.__cfg.female_name
			end

			return race.name
		end

		return JOURNEYLOG_UI_RACE_PLACEHOLDER
	end

	local function bio_status_helper(status)
		return BIO_STATUS_LABELS[status] or JOURNEYLOG_UI_STATUS_PLACEHOLDER
	end

	local function populate_lore_entry_list(self)
		self.archive_obj_list:remove_items_at(1, 0)
		if archive_mode == ARCHIVE_MODE_CHARACTERS then
			for i, profile in ipairs(archive.profiles) do
				local archive_item = self.archive_obj_list:add_item()
				archive_item.archive_item_label.label = profile.name
			end
		elseif archive_mode == ARCHIVE_MODE_WORLD then
			for i, entry in ipairs(archive.world) do
				local archive_item = self.archive_obj_list:add_item()
				archive_item.archive_item_label.label = entry.title
			end
		end
	end

	local function show_chara_bio(self, index)
		if not index or index > #archive.profiles then
			self.archive_entry.visible = false
			return
		end

		local profile = archive.profiles[index]

		if not profile then
			jprintf(W_ERR, "could not load profile (corrupt lore cache?)")
			return
		end

		self.archive_entry:remove_items_at(1, 0)

		local page = self.archive_entry:add_item_of_type("chara_profile")

		page.archive_entry_title.marked_up_text = ("<big>%s</big>"):format(profile.name)
		page.archive_entry_body.marked_up_text = transform_markup(profile.description) or JOURNEYLOG_UI_BIO_PLACEHOLDER

		page.chara_portrait.label = profile.portrait or ""
		page.race.marked_up_text = bio_race_name_helper(profile.race, profile.gender)
		page.status.marked_up_text = bio_status_helper(profile.status)
		page.affiliation.marked_up_text = profile.affiliation or JOURNEYLOG_UI_GROUPS_PLACEHOLDER
		page.additional_titles.marked_up_text = profile.additional_titles or JOURNEYLOG_UI_TITLES_PLACEHOLDER

		-- FIXME: Wesnoth 1.18 does not appear to support setting .visible on grids
		--        in Lua even though it is supported in C++

		if not profile.status then
			page.status.visible = false
			page.status_heading.visible = false
		end

		if not profile.additional_titles then
			page.additional_titles.visible = false
			page.additional_titles_heading.visible = false
		end

		if not profile.portrait then
			page.chara_portrait.visible = false
		else
			page.chara_portrait.on_button_click = portrait_image_viewer(profile.portrait, profile.name)
		end

		if not profile.help_unit_type then
			page.unit_type_help.visible = false
		else
			page.unit_type_help.on_button_click = function()
				gui.show_help(("unit_%s"):format(profile.help_unit_type))
			end
		end
	end

	local function show_world_lore_entry(self, index)
		if not index or index > #archive.world then
			self.archive_entry.visible = false
			return
		end

		local entry = archive.world[index]

		if not entry then
			jprintf(W_ERR, "could not load world lore entry (corrupt lore cache?)")
			return
		end

		self.archive_entry:remove_items_at(1, 0)

		local page = self.archive_entry:add_item_of_type("lore_entry")

		page.archive_entry_title.marked_up_text = ("<big>%s</big>"):format(entry.title)
		page.archive_entry_body.marked_up_text = transform_markup(entry.text) or JOURNEYLOG_UI_BIO_PLACEHOLDER
	end

	local function show_archive_item(self, index, force)
		if not force and index == current_page then
			return
		end

		if archive_mode == ARCHIVE_MODE_CHARACTERS then
			show_chara_bio(self, index)
		elseif archive_mode == ARCHIVE_MODE_WORLD then
			show_world_lore_entry(self, index)
		end

		current_page = index
	end

	local function show_tab(self, tab_num)
		self.tabs_container.selected_index = tab_num
		self.title.label = UI_TAB_LABELS[tab_num] or "OUT_OF_RANGE"

		if tab_num == 1 then
			self.scenario_list:focus()
			self.show_portraits.visible = true
			self.search_box.visible = true
		elseif tab_num == 2 then
			self.archive_obj_list:focus()
			self.show_portraits.visible = false
			self.search_box.visible = false
		end
	end

	local function preshow(self)
		for i, campaign in ipairs(journeylog.enumerate_campaigns()) do
			if campaign.id == wesnoth.scenario.campaign.id then
				current_campaign = i
				self.campaigns_menu.label = clean_campaign_name(campaign.name)
			end

			local campaign_journey = {
				id = campaign.id,
				name = campaign.name,
				scenarios = {},
			}

			for j, scenario in ipairs(journeylog.enumerate_scenarios(campaign.id)) do
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

			table.insert(journal, campaign_journey)
		end

		for i, profile in ipairs(journeylog.retrieve_character_profiles()) do
			local archive_item = self.archive_obj_list:add_item()
			archive_item.archive_item_label.label = profile.name
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
			for i, campaign in ipairs(journal) do
				table.insert(menu_table, {
					label = campaign.name
				})
			end

			local index = gui.show_menu(menu_table)
			if index > 0 then
				current_campaign = index
				self.campaigns_menu.label = clean_campaign_name(journal[index].name)
				show_journey(self, index, 0, true)
			end
		end

		self.show_portraits.selected = global_show_portraits

		self.scenario_list.selected_index = current_scenario
		update_scenario_icon(self)

		self.scenario_list.on_modified = function()
			update_scenario_icon(self)
			show_journey(self, current_campaign, self.scenario_list.selected_index)
		end

		self.search_box.on_modified = function()
			set_journey_filter(self, self.search_box.text)
		end

		self.show_portraits.on_modified = function()
			set_journey_portraits_shown(self, self.show_portraits.selected)
		end

		self.archive_obj_list.on_modified = function()
			show_archive_item(self, self.archive_obj_list.selected_index)
		end

		self.log_section_selector.on_modified = function()
			show_tab(self, self.log_section_selector.selected_index)
		end

		self.archive_mode.on_modified = function()
			archive_mode = self.archive_mode.selected_index
			populate_lore_entry_list(self)
			show_archive_item(self, 1, true)
		end

		if not JOURNEYLOG_ALLOW_BROKEN_GARBAGE then
			self.campaigns_menu.visible = false
		end

		-- Set the initial selection.
		show_journey(self, current_campaign, current_scenario, true)
		populate_lore_entry_list(self)
		show_archive_item(self, 1, true)
		show_tab(self, 1)

		self.title.visible = false
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
	wesnoth.sync.run_unsynced(function() journeylog_ui() end)
end

--
-- Create WML context menu items
--

wesnoth.wml_actions.set_menu_item {
	id = "naia:journeylog",
	description = _ "Journal",
	image = "icons/menu-journeylog.png",
	T.default_hotkey {
		key = "j",
	},
	T.command {
		T.journeylog {}
	}
}
