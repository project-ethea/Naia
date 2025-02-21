--
-- Campaign intro dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2024 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

gui.add_widget_definition("window", "naia_campaign_intro", {
	id = "naia_campaign_intro",
	description = "Campaign intro billboard",

	T.resolution {
		-- Mystery magic numbers from _GUI_RESOLUTION_BORDERLESS_BASE, found
		-- in data/gui/widget/window_borderless.cfg on Wesnoth 1.18.
		left_border = 10,
		right_border = 13,
		top_border = 10,
		bottom_border = 13,

		-- We paint the whole screen black to hide the loading screen behind
		-- our dialog.
		T.background {
			T.draw {
				T.rectangle {
					x = 0,
					y = 0,
					w = "(width)",
					h = "(height)",
					fill_color = "0, 0, 0, 255"
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
					horizontal_alignment = "center",
					vertical_alignment = "center",
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

local INTRO_DIALOG = {
	maximum_width = 800,
	maximum_height = 900,

	click_dismiss = true,
	definition = "naia_campaign_intro",

	T.helptip { id = "tooltip_large" },
	T.tooltip { id = "tooltip_large" },

	T.grid {
		T.row {
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
			T.column {
				horizontal_alignment = "center",
				border = "all",
				border_size = 10,
				T.image {
					label = "misc/loadscreen_decor.png~BLEND(162, 127, 68, 1.0)"
				}
			}
		},
		T.row {
			T.column {
				border = "all",
				border_size = 5,
				vertical_alignment = "top",
				horizontal_alignment = "center",
				T.scroll_label {
					id = "message",
					text_alignment = "center"
				}
			}
		},
		T.row {
			T.column {
				T.spacer {
					height = 10
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
								definition = "gold",
								use_markup = true,
								label = "<span size='larger'>" .. ( _ "Press when ready to start") .. "</span>"
							}
						},
						T.column {
							border = "all",
							border_size = 5,
							T.image {
								label = "icons/arrows/short_arrow_ornate_right_30.png"
							}
						}
					}
				}
			}
		}
	}
}

--[[

Campaign intro dialog.

This is intended to display information or warnings to players regarding
campaign gameplay features.

[campaign_intro_screen]
	title=
	image=
	message=
[/campaign_intro_screen]

]]
local function campaign_intro_screen_impl(cfg)
	local title = cfg.title
	local image = cfg.image
	local message = cfg.message
	local music = cfg.music

	local current_playlist = wesnoth.audio.music_list.all

	if music then
		-- Replace playlist temporarily
		wesnoth.audio.music_list.clear()
		wesnoth.audio.music_list.play(music)
	end

	local function preshow(self)
		self.title.label = title
		self.message.marked_up_text = message

		if image then
			self.image.label = image
		else
			self.image.visible = false
		end

		self.title.visible = false
	end

	gui.show_dialog(INTRO_DIALOG, preshow)

	if music then
		-- Restore original playlist
		local i = 1
		for music_wml in wml.child_range(current_playlist, "music") do
			wesnoth.audio.music_list[i] = music_wml
			i = i + 1
		end
	end
end

function wesnoth.wml_actions.campaign_intro_screen(cfg)
	-- This is just a simple user interface for the story screen preamble, we
	-- do not need this in the replay.
	wesnoth.sync.run_unsynced(function() campaign_intro_screen_impl(cfg) end)
end

function wesnoth.wml_actions.story_unsynced(cfg)
	local title = wesnoth.scenario.name
	gui.show_story(cfg, title)
end
