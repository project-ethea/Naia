--
-- [item_prompt] dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2019 - 2020 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

---
-- Displays a prompt for confirming item pick-ups.
--
-- [item_prompt]
--     # Message box icon (wesnoth-icon.png by default)
--     image=(string)
--     # Plays a sound when the item is picked up.
--     sound=(string)
--
--     # Commands to execute when the item pick-up is confirmed.
--     [command]
--         # EventWML
--     [/command]
-- [/item_prompt]
---
function wesnoth.wml_actions.item_prompt(cfg)
	local dd = {
		maximum_width = 800,
		maximum_height = 600,

		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field

		T.grid {
			T.row {
				T.column {
					T.grid {
						T.row {
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "center",
								vertical_alignment = "center",

								T.image {
									id = "image",
									label = "wesnoth-icon.png~SCALE(96, 96)"
								}
							},
							T.column {
								vertical_alignment = "top",
								horizontal_alignment = "left",

								T.grid {
									T.row {
										T.column {
											border = "all",
											border_size = 5,
											vertical_alignment = "top",
											horizontal_alignment = "left",

											T.label {
												id = "caption",
												definition = "title",
												label = wgettext("Confirm")
											}
										}
									},

									T.row {
										T.column {
											border = "all",
											border_size = 5,
											vertical_alignment = "top",
											horizontal_alignment = "left",

											T.label {
												id = "message",
												wrap = true
											}
										}
									}
								}
							}
						}
					}
				}
			},
			T.row {
				T.column {
					horizontal_alignment = "right",

					T.grid {
						T.row {
							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "right",

								T.button { id = "ok", label = wgettext("Yes"), return_value = 1 }
							},

							T.column {
								border = "all",
								border_size = 5,
								horizontal_alignment = "right",

								T.button { id = "quit", label = wgettext("No"), return_value = 2 }
							}
						}
					}
				},
			}
		}
	}

	local image = cfg.image
	local sound = cfg.sound

	local branch_then = wml.get_child(cfg, "then") or
		helper.wml_error("[item_prompt] Missing mandatory [then] branch")
	local branch_else = wml.get_child(cfg, "else")

	if image == nil then
		-- Try to guess the icon from the first [object] in the command
		-- sequence.

		local first_object = wml.get_child(branch_then, "object")

		if first_object then
			image = first_object.image
		end
	end

	local res = wesnoth.synchronize_choice(function()
		return { value = wesnoth.show_dialog(dd, function()
			-- #textdomain wesnoth-Naia
			local _ = wesnoth.textdomain "wesnoth-Naia"
			local message = _ "Do you want this unit to pick up this item?"

			wesnoth.set_dialog_value(message, "message")

			if image ~= nil and tostring(image):len() > 0 then
				wesnoth.set_dialog_value(image, "image")
			end
		end)}
	end)

	res.value = math.abs(res.value) -- keyboard Enter/Esc are -1 and -2

	if res.value == 1 then
		if sound ~= nil then
			wesnoth.play_sound(sound)
		end

		utils.handle_event_commands(branch_then, "conditional")
	elseif res.value == 2 then
		if branch_else then
			utils.handle_event_commands(branch_else, "conditional")
		end

		wesnoth.allow_undo()
	end
end
