--
-- Wesnoth Journey Log module (back-end)
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local journeylog_milestones = {}

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

function journeylog.unlock_milestone(milestone_ids)
	for _, id in ipairs(stringx.split(milestone_ids)) do
		journeylog_milestones[id] = true
	end
	jprintf(W_INFO, "milestone unlocked: %s; will rebuild lore", milestone_ids)
	journeylog.rebuild_lore()
end
