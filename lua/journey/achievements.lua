--
-- Wesnoth Journey Log module (back-end)
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

-- Contains achievement group ids mapped to tables; these in turn contain the
-- original achievement ids.
local groups = {}

-- This exists solely because it is possible for the achievements table to not
-- be empty yet contain zero achievements if filled with empty achievement
-- groups.
local have_achievements = false

-- This module exists primarily to address a massive shortcoming in Wesnoth
-- 1.18's achievement system regarding progression: achievements which require
-- a certain number goal to be hit can be progressed to 100% during any number
-- of playthroughs, rather than on a single playthrough. For example, an
-- achievement that involves killing 100 units can be fulfilled by repeatedly
-- reloading a single save to kill the same singular unit.
--
-- Another big shortcoming of the achievement system is that while there are
-- APIs to interact with individual achievements, there is no way to enumerate
-- all of them -- we MUST have prior knowledge of achievements to do anything
-- meaningful with them.

function journeylog.have_achievements()
	return have_achievements
end

local function register_achievement_group(cfg)
	local id = cfg.content_for
	local name = cfg.display_name

	wprintf(W_INFO, "registering achievement group %s", id)

	if groups[id] == nil then
		groups[id] = {
			name         = name,
			achievements = {}
		}
	end

	for ach in wml.child_range(cfg, "achievement") do
		have_achievements = true
		table.insert(groups[id].achievements, ach.id)
	end
end

function journeylog.register_achievements(cfg)
	for group_cfg in wml.child_range(cfg, "achievement_group") do
		register_achievement_group(group_cfg)
	end
end

local function enumerate_achievement_impl(group_id, achievement_id)
	local cfg = wesnoth.achievements.get(group_id, achievement_id)
	local have_achieve = wesnoth.achievements.has(group_id, achievement_id)

	local function maybe_complete(attr_name)
		if have_achieve then
			return cfg[attr_name .. "_completed"]
		else
			return cfg[attr_name]
		end
	end

	local name = maybe_complete("name") or "<unknown>"
	local description = maybe_complete("description") or "<unknown>"
	local icon = maybe_complete("icon") or "misc/blank-hex.png"

	if icon == "~GS()" then
		-- Wesnoth likes this for some reason, yuck.
		icon = "misc/blank-hex.png"
	end

	return {
		id               = achievement_id,
		name             = name,
		description      = description,
		icon             = icon,
		hidden           = cfg.hidden or false,
		current_progress = cfg.current_progress,
		max_progress     = cfg.max_progress,
		completed        = have_achieve,
	}
end

function journeylog.enumerate_achievements()
	-- TODO FIXME we currently merge everything into one big list. This is not
	-- exactly ideal, but it'll do for the sake of shipping an achievements UI
	-- in version 1.0.
	local res = {}

	for group_id, group in pairs(groups) do
		for _, ach_id in ipairs(group.achievements) do
			table.insert(res, enumerate_achievement_impl(group_id, ach_id))
		end
	end

	return res
end
