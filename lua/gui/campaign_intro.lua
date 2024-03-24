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

local INTRO_DIALOG_MAIN_GRID = {
	T.row {
		T.column {
			border= "all",
			border_size = 5,
			vertical_alignment = "top",
			horizontal_alignment = "left",
			T.label {
				id = "title",
				definition = "title"
			}
		}
	},
	T.row {
		T.column {
			T.spacer {
				height = 10,
			}
		}
	},
	T.row {
		T.column {
			border = "all",
			border_size = 5,
			vertical_alignment = "top",
			horizontal_alignment = "left",
			T.scroll_label {
				id = "message"
			}
		}
	}
}

local INTRO_DIALOG = {
	maximum_width = 800,
	maximum_height = 900,

	click_dismiss = true,
	definition = "message",

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
			T.column {
				vertical_alignment = "top",
				horizontal_grow = true,
				T.grid(INTRO_DIALOG_MAIN_GRID)
			}
		},
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
