--
-- Wesnoth Journey Log module (back-end)
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 - 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local journeylog_milestones = {}
local journeylog_fragments = {}

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local JOURNEYLOG_WML_STORE = "__naia_journeylog_progression"
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

local function wmlpath(path)
	return ("%s.%s"):format(JOURNEYLOG_WML_STORE, path)
end

local function deserialize_journeylog_prog_state()
	wprintf(W_INFO, "reading journeylog state from WML")

	journeylog_milestones = {}
	journeylog_fragments = {}

	local milestones_wml = wml.variables[wmlpath("milestones")]

	for _, milestone in ipairs(stringx.split(milestones_wml or "")) do
		journeylog_milestones[milestone] = true
	end

	local lore_cfg = wml.variables[wmlpath("lore_fragments")]

	for entry_id, fragments_wml in pairs(lore_cfg or {}) do
		journeylog_fragments[entry_id] = {}
		for _, fragment in ipairs(stringx.split(fragments_wml or "")) do
			journeylog_fragments[entry_id][fragment] = true
		end
	end
end

local function serialize_journeylog_prog_state()
	wprintf(W_INFO, "saving journeylog state to WML")

	local milestones = {}

	for milestone, state in pairs(journeylog_milestones) do
		if state then
			table.insert(milestones, milestone)
		end
	end
	wml.variables[wmlpath("milestones")] = stringx.join(milestones)

	for entry_id, fragment_set in pairs(journeylog_fragments) do
		local lore_fragments = {}
		for fragment_id, state in pairs(fragment_set) do
			if state then
				table.insert(lore_fragments, fragment_id)
			end
		end
		wml.variables[wmlpath(("lore_fragments.%s"):format(entry_id))] = stringx.join(lore_fragments)
	end
end

--[[
local function wml_add_milestone_fast(milestone_id)
	local newval = wml.variables[wmlpath("milestones")]
	if newval ~= nil and newval ~= "" then
		newval = newval .. "," .. milestone_id
	else
		newval = milestone_id
	end
	wml.variables[wmlpath("milestones")] = newval
end

local function wml_add_fragment_fast(entry_id, fragment_id)
	local newval = wml.variables[wmlpath(("lore_fragments.%s"):format(entry_id))]
	if newval ~= nil and newval ~= "" then
		newval = newval .. "," .. fragment_id
	else
		newval = fragment_id
	end
	wml.variables[wmlpath(("lore_fragments.%s"):format(entry_id))] = newval
end
]]--

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
	if type(milestone_ids) == "table" then
		for _, id in ipairs(milestone_ids) do
			journeylog_milestones[id]= true
		end
	else
		for _, id in ipairs(stringx.split(milestone_ids)) do
			journeylog_milestones[id] = true
		end
	end
	jprintf(W_INFO, "milestone unlocked: %s; will rebuild lore", milestone_ids)
	journeylog.rebuild_lore()
	serialize_journeylog_prog_state()

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
	serialize_journeylog_prog_state()

	if show_notification then
		milestone_ui_impl( _ "Findings recorded — %s to browse journal")
	end
end

function wesnoth.wml_actions.unlock_milestone(cfg)
	local milestone = cfg.milestone or wml.error("[unlock_milestone] No milestone= specified")
	local notification = cfg.notification
	if notification == nil then
		notification = true
	end
	journeylog.unlock_milestone(cfg.milestone, notification)
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

-- Read state from saved games on Lua init
deserialize_journeylog_prog_state()
