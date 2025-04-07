--
-- Wesnoth Journey Log module (back-end)
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local journeylog_milestones = {}
local journeylog_fragments = {}

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local JOURNEYLOG_UI_HOTKEY = "j"

local function milestone_ui_impl(banner_text)
	local banner = ("<span color='#fd8'>★</span> %s"):format(
		tostring( _ "New knowledge unlocked — %s to browse journal"):format(
			"<span color='#fd8' face='monospace' weight='bold'>" ..
			JOURNEYLOG_UI_HOTKEY ..
			"</span>"
		))
	wesnoth.interface.add_overlay_text(banner, {
		color = "eeeeee",
		-- FIXME: bg causes an annoying flicker during fade on mac as of 1.18.3
		--bgcolor = "000000",
		--bgalpha = 127,
		size = 13,
		halign = "right",
		valign = "top",
		location = { 10, 10 },
		duration = 3000,
		fade_time = 1500
	})
end

function journeylog.has_milestone(milestone_ids)
	if milestone_ids == nil or milestone_ids == "" then
		return true
	end

	for _, id in ipairs(stringx.split(milestone_ids)) do
		if not journeylog_milestones[id] then
			return false
		end
	end

	return true
end

function journeylog.has_lore_fragment(entry_id, fragment_id)
	if entry_id == nil or entry_id == "" or fragment_id == nil or fragment_id == "" then
		return false
	end

	if not journeylog_fragments[entry_id] then
		return false
	end

	return not not journeylog_fragments[entry_id][fragment_id]
end

function journeylog.unlock_milestone(milestone_ids, show_notification)
	for _, id in ipairs(stringx.split(milestone_ids)) do
		journeylog_milestones[id] = true
	end
	jprintf(W_INFO, "milestone unlocked: %s; will rebuild lore", milestone_ids)
	journeylog.rebuild_lore()

	if show_notification then
		milestone_ui_impl( _ "New knowledge unlocked — %s to browse journal")
	end
end

function journeylog.record_lore_fragment(entry_id, fragment_ids, show_notification)
	if not journeylog_fragments[entry_id] then
		journeylog_fragments[entry_id] = {}
	end

	for _, fragment_id in ipairs(stringx.split(fragment_ids)) do
		journeylog_fragments[entry_id][fragment_id] = true
		jprintf(W_INFO, "fragment id unlocked: %s.%s; will rebuild lore", entry_id, fragment_id)
	end

	journeylog.rebuild_lore()

	if show_notification then
		milestone_ui_impl( _ "Findings recorded — %s to browse journal")
	end
end

function wesnoth.wml_actions.record_lore_fragment(cfg)
	local notification = cfg.notification
	if notification == nil then
		notification = true
	end
	journeylog.record_lore_fragment(cfg.entry, cfg.fragment, notification)
end

--[[
function naia_milestones_ui_test()
	milestone_ui_impl()
end
]]--
