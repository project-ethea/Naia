--
-- [transient_message] dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2021 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

---
-- Displays a transparent message box that's dimissed when clicked.
--
-- [transient_message]
--     caption=(tstring)
--     message=(tstring)
--     transparent=(boolean)
--     image=(image path)
--     sound=(string)
-- [/transient_message]
---
function wesnoth.wml_actions.transient_message(cfg)
	local dd = {
		maximum_width = 800,
		maximum_height = 600,
		click_dismiss = true,
		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field

		T.grid {
			T.row {
				T.column {
					border = "all", border_size = 5,
					horizontal_alignment = "center",
					vertical_alignment = "center",
					T.image { id = "image" }
				},
				T.column {
					vertical_alignment = "top",
					horizontal_alignment = "left",
					T.grid {
						T.row {
							T.column {
								border = "all", border_size = 5,
								vertical_alignment = "top",
								horizontal_alignment = "left",
								T.label {
									id = "caption",
									definition = "title"
								}
							}
						},
						T.row {
							T.column {
								border = "all", border_size = 5,
								vertical_alignment = "top",
								horizontal_alignment = "left",
								T.label {
									id = "message",
									definition = "wml_message",
									wrap = true
								}
							}
						}
					}
				}
			}
		}
	}

	local transparent = cfg.transparent
	if transparent == nil then transparent = true end

	if transparent then
		dd.definition = "message"
	end

	local caption = cfg.caption
	if caption == nil then caption = "" end
	local message = cfg.message
	if message == nil then message = "" end

	local function preshow()
		wesnoth.set_dialog_value(caption, "caption")
		wesnoth.set_dialog_value(message, "message")
		wesnoth.set_dialog_markup(true, "message")

		if cfg.image ~= nil and tostring(cfg.image):len() > 0 then
			wesnoth.set_dialog_value(cfg.image, "image")
		else
			wesnoth.set_dialog_visible(false, "image")
		end
	end

	local sound = cfg.sound
	if sound ~= nil then wesnoth.audio.play(sound) end

	wesnoth.show_dialog(dd, preshow, nil)
end
