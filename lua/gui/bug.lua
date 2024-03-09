--
-- Bug check report dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2024 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

--[[

Displays an error message on a popup dialog.

This is intended to be used as an exit mechanism when the WML detects an
inconsistency (see the BUG and BUG_ON macros in core/debug.cfg

[bug]
    # String
    message=""

    # Boolean
    may_ignore=yes

    # Boolean
    should_report=yes

    # Either "forum" or "tracker", only used if should_report=yes.
    feedback="forum"

    # Optional bug condition. If provided, the bug check message is only
    # triggered if the condition evalutes to a true value.
    [condition]
        # WML condition here
    [/condition]
[/bug]

]]
function wesnoth.wml_actions.bug(cfg)
	local cond = wml.get_child(cfg, "condition")

	if cond and not wml.eval_conditional(cond) then
		return
	end

	local report = cfg.should_report
	local notice = cfg.message
	local log_notice = notice
	local may_ignore = cfg.may_ignore
	local feedback = cfg.feedback

	if feedback == nil or (feedback ~= "tracker" and feedback ~= "omgbugseverywhere") then
		feedback = "forum"
	end

	if log_notice == nil or log_notice == "" then
		log_notice = "inconsistency detected"
	end

	if report == nil then
		report = true
	end

	if may_ignore == nil then
		may_ignore = true
	end

	wput(W_ERR, "BUG: " .. log_notice)

	local alert_dialog = {
		maximum_width = 640,
		maximum_height = 900,
		T.helptip { id="tooltip_large" },
		T.tooltip { id="tooltip_large" },
		T.grid {
			T.row {
				T.column {
					horizontal_alignment = "left",
					grow_factor = 1,
					border = "all",
					border_size = 5,
					T.label {
						definition = "title",
						id = "title",
						wrap = true
					}
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.label {
						id = "message",
						wrap = true
					}
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.label {
						id = "feedback",
						wrap = true
					}
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.spacer {}
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					T.panel {
						id = "details_area",
						T.grid {
							T.row {
								T.column {
									horizontal_alignment = "left",
									border = "all",
									border_size = 5,
									T.label {
										id = "message2",
										label = _("The following WML condition was unexpectedly reached:"),
										wrap = true
									}
								}
							},
							T.row {
								T.column {
									vertical_alignment = "center",
									horizontal_grow = "true",
									border = "all",
									border_size = 5,
									T.scroll_label {
										id = "dump",
										definition = "verbatim",
										vertical_scrollbar_mode = "always"
									}
								},
							}
						}
					}
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								grow_factor = 1,
								T.button {
									id = "details_button",
									label = _("Details")
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.button {
									id = "ok",
									label = wgettext("Continue"),
									return_value = 1
								}
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.button {
									id = "quit",
									label = wgettext("Quit"),
									return_value = 2
								}
							}
						}
					}
				}
			}
		}
	}

	local function preshow(self)
		local msg = _ "An inconsistency has been detected, and the scenario might not continue working as originally intended."

		if notice ~= nil and notice ~= "" then
			if feedback ~= "omgbugseverywhere" then
				msg = ("%s\n\n%s\n\t%s\n"):format(
					msg, _("Message:"), cfg.message)
			else
				-- HACK: for the experimental version notice
				msg = cfg.message
			end
		end

		local feedback_msg = nil

		if report then
			if feedback == "forum" then
				feedback_msg = _ "Please report this to the add-on maintainer on the forums:"
				feedback_msg = feedback_msg .. "\n" .. naia_get_package_url()[1]
			elseif feedback == "tracker" then
				feedback_msg = _ "Please report this to the add-on maintainer on the issue tracker:"
				feedback_msg = feedback_msg .. "\n" .. naia_get_package_url()[2]
			elseif feedback == "omgbugseverywhere" then
				feedback_msg = naia_get_package_url()[2]
			else
				wprintf(W_ERR, "Unknown [bug] feedback= value '%s'", feedback)
			end
		end

		if feedback == "omgbugseverywhere" then
			self.title.label = _("Notice")
			self.details_button.visible = false
		else
			self.title.label = _("Error")
		end

		self.message.marked_up_text = msg

		if feedback_msg then
			self.feedback.marked_up_text = feedback_msg
		else
			self.feedback.visible = false
		end

		if cond then
			self.details_button.on_button_click = function()
				self.details_area.visible = true
				self.details_button.enabled = false
			end
			self.dump.label = wml.tostring(cond)
		else
			self.details_button.enabled = false
		end

		if not may_ignore then
			self.ok.enabled = false
		end

		self.details_area.visible = false
	end

	local dialog_result = gui.show_dialog(alert_dialog, preshow, nil)

	if wesnoth.game_config.debug then
		wesnoth.wml_actions.inspect {}
	end

	if dialog_result == 2 or not may_ignore then
		die()
	end
end
