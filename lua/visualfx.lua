--
-- Visual effects library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--
-- Includes code vaguely inspired by Durzi's Animated Weather & Scenery add-on
-- (1.18 version).
--

local T = wml.tag

--
-- General private functions
--

local function synced_random_50()
	return mathx.random(0, 1) == 1
end

local function format_random_frame_spec(namestem, frame_count, frame_time, ipf)
	local start_frame = mathx.random(1, frame_count)
	local frames = {}

	if start_frame == 1 then
		table.insert(frames, { 1, frame_count })
	else
		if start_frame ~= frame_count  then
			table.insert(frames, { start_frame, frame_count })
		else
			table.insert(frames, { start_frame })
		end

		if start_frame > 2 then
			table.insert(frames, { 1, start_frame - 1 })
		else
			table.insert(frames, { 1 })
		end
	end

	local filenames = {}
	local suffix = ""

	if ipf ~= nil then
		suffix = ipf
	end

	for _, spec in ipairs(frames) do
		if #spec == 2 then
			table.insert(filenames, string.format("%s[%d~%d].png%s:%d", namestem, spec[1], spec[2], suffix, frame_time))
		elseif #spec == 1 then
			table.insert(filenames, string.format("%s[%d].png%s:%d", namestem, spec[1], suffix, frame_time))
		else
			wml.error("zoinks!")
		end
	end

	return stringx.join(filenames)
end

local function have_named_item(loc, item_id)
	local item_info = wesnoth.interface.get_items({ loc.x, loc.y })
	if #item_info > 0 then
		for _, item in ipairs(item_info) do
			if item.name == item_id then
				return true
			end
		end
	end
	return false
end

--
-- Fireflies
--

local fireflies = {
	namestem = "terrain/environment/fireflies-",
	frames   = 121,
	time     = 130,
	wml_id   = "__naia_envfx_fireflies",
}

local function fireflies_single(x, y, prob)
	if prob <= 0 or ( prob < 100 and mathx.random() > prob / 100 ) then
		return
	end

	local ipf = ""

	if synced_random_50() then ipf = ipf .. "vert" end
	if synced_random_50() then ipf = ipf .. "horiz" end

	if ipf ~= "" then
		ipf = ("~FL(%s)"):format(ipf)
	end

	local frame_spec = format_random_frame_spec(fireflies.namestem, fireflies.frames, fireflies.time, ipf)
	local item_cfg = {
		x      = x,
		y      = y,
		halo   = frame_spec,
		name   = fireflies.wml_id,
		redraw = false,
	}

	if wml.variables[fireflies.wml_id] == nil then
		wml.variables[fireflies.wml_id] = item_cfg
	else
		local new_index = wml.variables[fireflies.wml_id .. ".length"]
		wml.variables[("%s[%d]"):format(fireflies.wml_id, new_index)] = item_cfg
	end
end

local function is_firefly_turn(loc)
	-- Only active during neutral/chaotic turns other than "dawn"
	return loc.time_of_day.lawful_bonus <= 0 and not loc.time_of_day.id:find("dawn")
end

local function fireflies_turn_controller()
	if wml.variables[fireflies.wml_id] == nil then
		-- Fireflies have not been configured for this scenario, nothing to do
		-- here then.
		return
	end

	local items = wml.array_access.get(fireflies.wml_id)

	-- We perform checks on *every* tile marked by [visualfx_setup_fireflies].
	-- This is more expensive than testing the first tile and calling it a day
	-- but it guarantees that [time_area] will be honored wherever needed.
	-- (Admittedly this is kind of pointless for IftU and AtS, maybe make it
	-- optional? TODO)
	for _, item in ipairs(items) do
		local loc = wesnoth.current.map.get({ item.x, item.y })
		local fireflies_on = have_named_item(loc, item.name)

		if is_firefly_turn(loc) and not fireflies_on then
			wesnoth.wml_actions.item(item)
			wesnoth.wml_actions.redraw {}
		elseif not is_firefly_turn(loc) and fireflies_on then
			wesnoth.wml_actions.remove_item { image = item.name }
			wesnoth.wml_actions.redraw {}
		end
	end
end

local function fireflies_cleanup()
	wml.variables[fireflies.wml_id] = nil
end

--
-- Adds fireflies on tiles matching a certain SLF, provided as WML.
--
-- [visualfx_setup_fireflies]
--     ... SLF ...
--     probability=60 # default
-- [/visualfx_setup_fireflies]
--
-- By default, hexes have a 60% chance of having fireflies added to them.
--
-- Fireflies are only active during chaotic turns and twilight (except for
-- turns whose time of day id includes 'dawn' in the name). This is checked at
-- the start of every turn for each matched location, taking time areas into
-- account.
--
-- NOTE: You should use this command on prestart or at least *before* the
-- visuals are supposed to be applied, e.g. before the 'new turn' event.
-- The reason for this is that they are not applied instantly; instead this
-- task is delegated to a 'new turn' event handler.
--
function wesnoth.wml_actions.visualfx_setup_fireflies(cfg)
	local locs = wesnoth.map.find(cfg)
	local prob = cfg.probability

	if prob == nil then
		prob = 60
	end

	if prob == 0 then
		return
	end

	if prob < 0 or prob > 100 then
		wml.error("[visualfx_setup_fireflies] Illegal probability= value")
	end

	for _, loc in ipairs(locs) do
		fireflies_single(loc.x, loc.y, prob)
	end
end

--
-- Hooks
--

-- start is dispatched before new turn, thus we need to hook into it too in
-- order to ensure graphics are updated before characters speak, etc.
on_event("start,new turn", fireflies_turn_controller)

-- cleanup to prevent savegame pollution
on_event("scenario end",   fireflies_cleanup)
