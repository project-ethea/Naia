--
-- Achievements module
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

-- The main purpose of this code is to override the usage of modal popups in
-- Wesnoth 1.18 to signal attaining an achievement. The only non-modal UI
-- system we have access to currently is [print], which means we lose the
-- ability to display the achievement icon. This will do for the time being,
-- since our primary goal is simply to stop notifications from interrupting
-- other gameplay.

local OVERLAY_FONT_SIZE = 13
-- y offset is (font_size) * 2 higher than that used by the
-- JourneyLog milestones notification so we don't paint over it
local OVERLAY_OFFSET    = { 10, 10 + 2 * OVERLAY_FONT_SIZE }

local _WA_setach = wesnoth.achievements.set
local _WA_setsubach = wesnoth.achievements.set_sub_achievement
local _WA_progach = wesnoth.achievements.progress
-- NOTE: we assume gui.show_popup is never patched after running this code
local _WA_gui2call = gui.show_popup

local function achievement_gui2call_impl(title, message, image)
	-- v1.18 places the name in param 1 and description in param 2. We have
	-- no use for param 3 because add_overlay_text cannot display images.
	local text = ("<span color='#fd8'>★</span> %s <span color='#fd8' weight='bold'>%s</span>\n     <span color='#fd8' size='smaller'>%s</span>"):format(
		_("Achievement unlocked:"),
		title,
		message)
	wesnoth.interface.add_overlay_text(text, {
		color = "eeeeee",
		size = OVERLAY_FONT_SIZE,
		halign = "right",
		valign = "top",
		location = OVERLAY_OFFSET,
		duration = 3000,
		fade_time = 1500
	})
end

local function achievement_api_patch_impl(realfunc, ...)
	-- Override gui.show_popup temporarily - strange things may happen if the
	-- Lua interpreter dies before we have a chance to restore this though
	gui.show_popup = achievement_gui2call_impl
	-- Only .progress has an actual return value
	local res = _WA_setach(...)
	gui.show_popup = _WA_gui2call
	return res
end

function wesnoth.achievements.set(...)
	return achievement_api_patch_impl(_WA_setach, ...)
end

function wesnoth.achievements.set_sub_achievement(...)
	return achievement_api_patch_impl(_WA_setsubach, ...)
end

function wesnoth.achievements.set_sub_achievement(...)
	return achievement_api_patch_impl(_WA_progach, ...)
end

--[[
function naia_achievements_ui_test()
	achievement_gui2call_impl(
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit",
		"Donec bibendum dui eget dolor tristique, ut commodo massa rutrum. Nunc pellentesque"
	)
end
]]--
