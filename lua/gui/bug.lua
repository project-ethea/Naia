--
-- Bug check report dialog
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2021 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

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

	if cond and not wesnoth.eval_conditional(cond) then
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
		T.helptip { id="tooltip_large" }, -- mandatory field
		T.tooltip { id="tooltip_large" }, -- mandatory field
		T.grid { -- Title, will be the object name
			T.row {
				T.column {
					horizontal_alignment = "left",
					grow_factor = 1, -- this one makes the title bigger and golden
					border = "all",
					border_size = 5,
					T.label { definition = "title", id = "title", wrap = true }
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.label { id = "message", wrap = true }
				}
			},
			T.row {
				T.column {
					horizontal_grow = true,
					border = "all",
					border_size = 5,
					T.label { id = "feedback", wrap = true }
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
									T.label { id = "message2", wrap = true }
								}
							},
							T.row {
								T.column {
									vertical_alignment = "center",
									horizontal_grow = "true",
									border = "all",
									border_size = 5,
									T.scroll_label {
										id = "wml",
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
								T.button { id = "details" }
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.button { id = "ok", label = wgettext("Continue"), return_value = 1 }
							},
							T.column {
								horizontal_alignment = "right",
								border = "all",
								border_size = 5,
								T.button { id = "quit", label = wgettext("Quit"), return_value = 2 }
							}
						}
					}
				}
			}
		}
	}

	local function show_details()
		wesnoth.set_dialog_visible(true, "details_area")
		wesnoth.set_dialog_active(false, "details")
	end

	local function preshow()
		-- #textdomain wesnoth-Naia
		local _ = wesnoth.textdomain "wesnoth-Naia"
		local msg = _ "An inconsistency has been detected, and the scenario might not continue working as originally intended."
		local msg2 = _ "The following WML condition was unexpectedly reached:"

		if notice ~= nil and notice ~= "" then
			if feedback ~= "omgbugseverywhere" then
				msg = msg .. "\n\n" .. _ "Message:"
				msg = msg .. "\n\t" .. cfg.message
				msg = msg .. "\n"
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

		local cap = _ "Error"
		local det = _ "Details"

		if feedback == "omgbugseverywhere" then
			cap = _ "Notice"
			wesnoth.set_dialog_visible(false, "details")
		end

		wesnoth.set_dialog_value(cap,  "title")
		wesnoth.set_dialog_value(msg,  "message")
		wesnoth.set_dialog_value(msg2, "message2")
		wesnoth.set_dialog_value(det,  "details")

		wesnoth.set_dialog_markup(true, "message")
		wesnoth.set_dialog_markup(true, "feedback")

		if feedback_msg then
			wesnoth.set_dialog_value(feedback_msg, "feedback")
		else
			wesnoth.set_dialog_visible(false, "feedback")
		end

		if cond then
			wesnoth.set_dialog_callback(show_details, "details")
			wesnoth.set_dialog_value(wml.tostring(cond), "wml")
		else
			wesnoth.set_dialog_active(false, "details")
		end

		if not may_ignore then
			wesnoth.set_dialog_active(false, "ok")
		end

		wesnoth.set_dialog_visible(false, "details_area")
	end

	local dialog_result = wesnoth.show_dialog(alert_dialog, preshow, nil)

	if wesnoth.game_config.debug then
		wesnoth.wml_actions.inspect {}
	end

	if dialog_result == 2 or not may_ignore then
		die()
	end
end
