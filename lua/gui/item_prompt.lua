--
-- [item_prompt] dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2019 - 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

---
-- Displays a prompt for confirming item pick-ups.
--
-- [item_prompt]
--     # Caption
--     # (default value is "Confirm")
--     caption=(string)
--     # Message text
--     # (default value is "Do you want this unit to pick up this item?")
--     message=(string)
--
--     # Message box icon (wesnoth-icon.png by default)
--     image=(string)
--     # Plays a sound when the item is picked up.
--     sound=(string)
--
--     # Commands to execute when the item pick-up is confirmed.
--     [then]
--         # EventWML
--     [/then]
--     # Commands to execute when the item pick-up is canceled.
--     [else]
--         # Event WML
--     [/else]
-- [/item_prompt]
---
function wesnoth.wml_actions.item_prompt(cfg)
	local caption = cfg.caption
	local message = cfg.message
	local image = cfg.image
	local sound = cfg.sound

	local image_alignment = "top"

	if image ~= nil and image ~= "" then
		local image_w, image_h = filesystem.image_size(image)
		-- Past size 60 it's probably not one of those framed icons
		if image_w > 60 or image_h > 60 then
			image_alignment = "center"
		end
	end

	local dd = {
		maximum_width = 700,
		maximum_height = 600,

		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field

		T.grid {
			T.row {
				T.column {
					border = "all",
					border_size = 10,
					horizontal_alignment = "center",
					vertical_alignment = image_alignment,

					T.image {
						id = "image",
						label = "wesnoth-icon.png~SCALE(96, 96)"
					}
				},
				T.column {
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
									label = _("Do you want this unit to pick up this item?"),
									wrap = true
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

											T.button {
												id = "ok",
												label = wgettext("Yes"),
												return_value = 1
											}
										},

										T.column {
											border = "all",
											border_size = 5,
											horizontal_alignment = "right",

											T.button {
												id = "quit",
												label = wgettext("No"),
												return_value = 2
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

	local branch_then = wml.get_child(cfg, "then") or
		wml.error("[item_prompt] Missing mandatory [then] branch")
	local branch_else = wml.get_child(cfg, "else")

	if image == nil then
		-- Try to guess the icon from the first [object] in the command
		-- sequence.

		local first_object = wml.get_child(branch_then, "object")

		if first_object then
			image = first_object.image
		end
	end

	local res = wesnoth.sync.evaluate_single(function()
		return { value = gui.show_dialog(dd, function(self)
			if caption ~= nil then
				self.caption.label = caption
			end

			if message ~= nil then
				self.message.marked_up_text = message
			end

			if image ~= nil and tostring(image):len() > 0 then
				self.image.label = image
			end
		end)}
	end)

	res.value = math.abs(res.value) -- keyboard Enter/Esc are -1 and -2

	if res.value == 1 then
		if sound ~= nil then
			wesnoth.audio.play(sound)
		end

		utils.handle_event_commands(branch_then, "conditional")
	elseif res.value == 2 then
		if branch_else then
			utils.handle_event_commands(branch_else, "conditional")
		end

		wesnoth.allow_undo()
	end
end
