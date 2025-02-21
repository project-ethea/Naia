--
-- Campaign gameplay notification change dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2024 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local gameplay_info_dlg = {
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
								label = "<span size='larger'>" .. ( _ "Continue") .. "</span>"
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

local function gameplay_notification_impl(cfg)
	local title = cfg.title
	local image = cfg.image
	local message = cfg.message
	local fade_screen = cfg.fade_screen

	if fade_screen == nil then
		fade_screen = true
	end

	local function preshow(self)
		self.message.marked_up_text = message

		if image then
			self.image.label = image
		else
			self.image.visible = false
		end

		if title then
			self.title.marked_up_text = title
		else
			self.title.visible = false
		end
	end

	if fade_screen then
		wesnoth.interface.screen_fade({0, 0, 0, 192}, 500)
	end

	gui.show_dialog(gameplay_info_dlg, preshow)

	if fade_screen then
		wesnoth.interface.screen_fade({0, 0, 0, 0}, 250)
	end
end

--[[

Gameplay notification dialog.

This is used to display information to players about changes to the campaign's
gameplay, whether positive or negative.

[gameplay_notification]
	title=<optional title text>
	image=<optional image path>
	message=<message text>
	fade_screen=<optional boolean, default yes>
[/gameplay_notification]

]]
function wesnoth.wml_actions.gameplay_notification(cfg)
	gameplay_notification_impl(cfg)
end
