--
-- Campaign intro dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2024 - 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local INTRO_PROMPT = _ "Continue"
local INTRO_DECORATION = "misc/loadscreen_decor.png~BLEND(162, 127, 68, 1.0)"

local INTRO_PAGE_TEXT_DEF = {
	id = "message",
	definition = "naia_campaign_intro_text",
	wrap = true,
	text_alignment = "center"
}

local INTRO_PAGE_DEFAULT = {
	id = "default",
	T.row {
		grow_factor = 0,
		T.column {
			border = "all",
			border_size = 10,
			vertical_alignment = "top",
			horizontal_alignment = "center",
			T.label(INTRO_PAGE_TEXT_DEF)
		}
	}
}

local INTRO_PAGE_SINGLE_OPTION = {
	id = "single_option",
	T.row {
		grow_factor = 0,
		T.column {
			border = "all",
			border_size = 10,
			vertical_alignment = "top",
			horizontal_alignment = "center",
			T.label(INTRO_PAGE_TEXT_DEF)
		}
	},
	T.row {
		grow_factor = 0,
		T.column {
			vertical_alignment = "top",
			horizontal_alignment = "center",
			T.grid {
				T.row {
					grow_factor = 0,
					T.column {
						border = "all",
						border_size = 10,
						vertical_alignment = "top",
						T.label {
							id = "checkbox_label",
							definition = "naia_campaign_intro_option_label",
							wrap = true,
							text_alignment = "right"
						}
					},
					T.column {
						border = "all",
						border_size = 10,
						vertical_alignment = "center",
						T.toggle_button {
							id = "checkbox",
							definition = "naia_campaign_options_checkbox",
						}
					}
				}
			}
		}
	}
}

local INTRO_DIALOG = {
	automatic_placement = false,
	x = 0,
	y = 0,
	width = "(screen_width)",
	height = "(screen_height)",

	definition = "naia_campaign_intro",

	T.helptip { id = "tooltip_large" },
	T.tooltip { id = "tooltip_large" },

	T.grid {
		T.row {
			grow_factor = 0,
			T.column {
				border = "all",
				border_size = 10,
				horizontal_alignment = "center",
				vertical_alignment = "top",
				T.image {
					id = "image"
				}
			},
		},
		T.row {
			grow_factor = 0,
			T.column {
				border= "all",
				border_size = 5,
				vertical_alignment = "top",
				horizontal_alignment = "center",
				T.label {
					id = "title",
					definition = "title"
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_alignment = "center",
				border = "all",
				border_size = 10,
				T.image {
					label = INTRO_DECORATION
				}
			}
		},
		T.row {
			grow_factor = 1,
			T.column {
				T.multi_page {
					id = "page_container",
					horizontal_scrollbar_mode = "never",
					T.page_definition(INTRO_PAGE_DEFAULT),
					T.page_definition(INTRO_PAGE_SINGLE_OPTION)
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				border = "all",
				border_size = 10,
				horizontal_grow = "true",
				T.label {
					id = "progress_bar",
					definition = "naia_campaign_intro_text",
					text_alignment = "center"
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_alignment = "center",
				border = "all",
				border_size = 10,
				T.image {
					label = INTRO_DECORATION
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				T.spacer {
					height = 10
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				T.grid {
					T.row {
						T.column {
							border = "all",
							border_size = 5,
							T.button {
								id = "continue_button",
								definition = "naia_campaign_intro_button",
								label = INTRO_PROMPT
							}
						}
					}
				}
			}
		}
	}
}

local function make_progress_bar(current, max)
	local bar = "<span size='125%' color='#a27f44'>"
	for i = 1, max do
		if i > 1 then
			bar = bar .. " "
		end
		if i ~= current then
			bar = bar .. "•"
		else
			bar = bar .. "<span color='#d7d7d7'>•</span>"
		end
	end
	return bar .. "</span>"
end

local function intro_page_impl(pages_cfg)
	local music = pages_cfg.music
	local current_playlist = wesnoth.audio.music_list.all

	if music then
		-- Replace playlist temporarily
		wesnoth.audio.music_list.clear()
		wesnoth.audio.music_list.play(music)
	end

	local initial_page = 0
	local pages = {}

	-- WML variable state that should be synced by the dialog's caller. This
	-- is REQUIRED to be a valid WML table by wesnoth.sync.evaluate_single:
	-- <https://wiki.wesnoth.org/LuaAPI/wesnoth/sync#wesnoth.sync.evaluate_single>
	local vars = {}

	local function select_page(self, num)
		-- Before potentially closing the dialog, commit options to our
		-- variable state table.

		local current = self.page_container.selected_index

		if current > 0 and current <= #pages and pages[current].variable ~= nil then
			-- FIXME: only a single value from a checkbox supported right now
			vars[pages[current].variable] = pages[current].ui.checkbox.selected
		end

		if num == nil then
			num = self.page_container.selected_index + 1
		end

		if num > #pages then
			return false
		end

		local page = pages[num]

		if page.title then
			self.title.label = page.title
			self.title.visible = true
		else
			self.title.visible = false
		end

		if page.image then
			self.image.label = page.image
			self.image.visible = true
		else
			self.image.visible = false
		end

		self.page_container.selected_index = num

		if num == #pages then
			self.continue_button.label = _ "Play"
		end

		self.progress_bar.marked_up_text = make_progress_bar(num, #pages)

		initial_page = num

		return true
	end

	local function preshow(self)
		pages = {}
		vars = {}

		for i, cfg in ipairs(pages_cfg) do
			local message = cfg.message
			local checkbox_cfg = wml.get_child(cfg, "checkbox")
			local checkbox_var = nil

			local page_type = "default"

			if checkbox_cfg then
				page_type = "single_option"
				checkbox_var = checkbox_cfg.variable
			end

			local page_widget = self.page_container:add_item_of_type(page_type)

			page_widget.message.marked_up_text = transform_markup(message)

			if checkbox_cfg and checkbox_var ~= nil then
				page_widget.checkbox.selected = checkbox_cfg.value
				page_widget.checkbox_label.marked_up_text = checkbox_cfg.label
				-- Initial value only. We set the final value when advancing
				-- the page.
				vars[checkbox_var] = checkbox_cfg.value
			end

			table.insert(pages, {
				placeholder = true,
				title       = cfg.title,
				image       = cfg.image,
				variable    = checkbox_var,
				ui          = page_widget,
			})
		end

		self.continue_button.on_button_click = function()
			if not select_page(self) then
				self:close()
			end
		end

		select_page(self, initial_page)
	end

	local res = -1

	-- Little trick to make enter/esc seem like they have the same effect as
	-- clicking on the button.
	while res < 0 do
		initial_page = initial_page + 1
		if #pages == 0 or initial_page <= #pages then
			res = gui.show_dialog(INTRO_DIALOG, preshow)
		else
			res = 0
		end
	end

	if music then
		-- Restore original playlist
		local i = 1
		for music_wml in wml.child_range(current_playlist, "music") do
			wesnoth.audio.music_list[i] = music_wml
			i = i + 1
		end
	end

	-- Pass any relevant state back to sync
	return vars
end

local function campaign_intro_screen_impl(cfg)
	local pages = {}

	if cfg.title or cfg.image or cfg.message then
		table.insert(pages, {
			title = cfg.title,
			image = cfg.image,
			message = cfg.message
		})
	end

	for page in wml.child_range(cfg, "page") do
		table.insert(pages, page)
	end

	return intro_page_impl(pages)
end

--[[

Campaign intro dialog.

This is intended to display information or warnings to players regarding
campaign gameplay features.

[campaign_intro_screen]
	# The attributes can be placed directly into the action WML tag, which
	# will cause them to be collected into a "page zero" of sorts. [page]
	# tags will have their content shown in order. If there is nothing to
	# display, this action does nothing.
	[page]
		title=
		image=
		message=
	[/page]
	[page]
		# ...
	[/page]
[/campaign_intro_screen]

]]
function wesnoth.wml_actions.campaign_intro_screen(cfg)
	local vars = wesnoth.sync.evaluate_single(function()
		return campaign_intro_screen_impl(cfg)
	end)

	for key, value in pairs(vars) do
		if type(value) == "table" then
			wml.error("FIXME: WML children not supported yet")
		end
		-- Copy scalar attribute
		wml.variables[key] = value
	end
end

function wesnoth.wml_actions.story_unsynced(cfg)
	local title = wesnoth.scenario.name
	gui.show_story(cfg, title)
end
