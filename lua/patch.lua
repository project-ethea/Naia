--
-- Mainline Lua/WML action compatibility or extension patches.
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2019 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

function log_patch(action_id, msg)
	wprintf(W_INFO, "PATCH [%s]: %s", action_id, msg)
end

---
-- Extends [remove_sound_source] to take a comma-separated list of sound
-- sources to remove.
---

log_patch("remove_sound_source", "comma-separated id list")

local _WA_remove_sound_source = wesnoth.wml_actions.remove_sound_source

function wesnoth.wml_actions.remove_sound_source(cfg)
	local ids = cfg.id or helper.wml_error("[remove_sound_source]: No id list provided")
	for id in ids:gmatch("[^,]+") do
		_WA_remove_sound_source { id = id:match "^%s*(.-)%s*$" }
	end
end

---
-- Fix for [change_theme] crashing when no theme is specified (fixed in version
-- 1.14.2).
---
if wesnoth.compare_versions(wesnoth.game_config.version, "<=", "1.14.1") then
	log_patch("change_theme", "crash on missing theme= attribute + explicit [redraw] required")

	function wesnoth.wml_actions.change_theme(cfg)
		local new_theme = cfg.theme

		if new_theme == nil then
			new_theme = ""
		end

		wesnoth.game_config.theme = new_theme

		wesnoth.wml_actions.redraw {}
	end
end

---
-- Workaround for Wesnoth issue #1617/AtS issue #31.
---

local _WA_animate_unit = wesnoth.wml_actions.animate_unit

function wesnoth.wml_actions.animate_unit(cfg)
	wesnoth.delay(1)
	_WA_animate_unit(cfg)
end

---
-- Add an option to fall back to some other unit (e.g. Mal Keshar) whenever
-- nonsentient undead need to talk in events.
--
-- Because we don't need the entire feature-set in practice for this particular
-- use case, only the most basic SUF functionality is supported in this mode:
--
--     speaker=
--     id=
--     x,y=
--
-- Non-SUF tags like [option] or [text_input] are passed onto the engine
-- [message] implementation, although care should be taken to not make
-- certain assumptions about the final selected unit.
--
-- The fallback conditions are specified in a [fallback_if] tag, which contains
-- a full SUF which, if the unit matched by the [message] SUF matches, triggers
-- the fallback unit selection. [fallback_to] specifies the SUF for the
-- fallback unit.
--
-- Only the first unit matched by any of the SUFs is used.
--
-- If [fallback_to] does not match anything then we catch on fire and violently
-- explode on the player's face. The license says "no warranty", after all.
---

log_patch("message", "[fallback_if]/[fallback_to]")

local _WA_message = wesnoth.wml_actions.message

function wesnoth.wml_actions.message(cfg)
	local fback_if_cfg = wml.get_child(cfg, "fallback_if")
	local fback_to_cfg = wml.get_child(cfg, "fallback_to")

	if not fback_if_cfg or not fback_to_cfg then
		_WA_message(cfg)
		return
	end

	if cfg.speaker == "narrator" then
		wprintf(W_WARN, "[message] has fallback information but speaker=narrator, fix this")
		_WA_message(cfg)
		return
	end

	wprintf(W_DBG, "[message] fallback check mode activated")

	cfg = wml.literal(cfg)

	local minisuf = {
		x = cfg.x,
		y = cfg.y,
		id = cfg.id
	}

	if cfg.speaker == "unit" then
		minisuf.x = wesnoth.current.event_context.x1
		minisuf.y = wesnoth.current.event_context.y1
	elseif cfg.speaker == "second_unit" then
		minisuf.x = wesnoth.current.event_context.x2
		minisuf.y = wesnoth.current.event_context.y2
	elseif cfg.speaker ~= nil then
		minisuf.speaker = cfg.speaker
	end

	local u = wesnoth.get_units(minisuf)[1]

	if not u then
		wprintf(W_ERR, "[message] root mini SUF in fallback check mode did not match anything, cannot show message (SUF too complex?)")
		return
	end

	if wesnoth.match_unit(u, fback_if_cfg) then
		wprintf(W_DBG, "[message] fallback triggered")
		u = wesnoth.get_units(fback_to_cfg)[1]

		if not u then
			wprintf(W_ERR, "[message] fallback SUF did not match anything, cannot show message")
			return
		end
	end

	-- We have a unit now, right?
	cfg.x, cfg.y = u.x, u.y
	cfg.id, cfg.speaker = nil, nil

	wprintf(W_DBG, "[message] engine call")

	_WA_message(cfg)
end

---
-- Extends several animation actions so that they do not trigger when the user
-- is skipping messages.
---

-- scroll, scroll_to, scroll_to_unit are not included here since they are
-- sometimes used to change the viewport position permanently after an event,
-- with the intention of aiding the player in deciding what their next course
-- of action should be. However, scroll_to and scroll_to_unit can become warp
-- actions.

local warp_actions = {
	"scroll_to",
	"scroll_to_unit",
	-- Special cases made to make fade_out_music and fade_out_sound_effects
	-- instantly mute either.
	"fade_out_music",
	"fade_out_sound_effects",
	-- fade_in_sound_effects needs to instantly raise volume to 100%.
	"fade_in_sound_effects",
}

local skippable_actions = {
	"move_unit_fake",
	"move_units_fake",
	"animate_unit",
	"sound",
	"delay",
	-- The lack of pauses can turn [color_adjust] into a health hazard, so
	-- skip that as well.
	"color_adjust",
	"fade_in",
	"fade_to_black",
	"floating_text",
}

local _WA_warp_actions = {}
local _WA_skip_actions = {}

for i, action_id in ipairs(warp_actions) do
	log_patch(action_id, "Warp on user skipping messages")

	_WA_warp_actions[action_id] = wesnoth.wml_actions[action_id]
	wesnoth.wml_actions[action_id] = function(cfg)
		if wesnoth.is_skipping_messages() then
			wprintf(W_INFO, "Ignoring timing or scrolling delay for [%s] while skipping [message]", action_id)

			if action_id == "fade_out_music" then
				wesnoth.music_list.clear()
				wesnoth.music_list.add("silence.ogg", true)
				-- HACK: give the new track a chance to start playing silently before
				--       resetting to full volume.
				wesnoth.delay(10)
				wesnoth.music_list.volume = 100.0
			elseif action_id == "fade_out_sound_effects" then
				wesnoth.sound_volume(0)
			elseif action_id == "fade_in_sound_effects" then
				wesnoth.sound_volume(100)
			else -- scroll_to* actions
				local p = wml.parsed(cfg)
				p.immediate = true
				_WA_warp_actions[action_id](p)
			end

			return
		end

		_WA_warp_actions[action_id](cfg)
	end
end

for i, action_id in ipairs(skippable_actions) do
	log_patch(action_id, "Skip on user skipping messages")

	_WA_skip_actions[action_id] = wesnoth.wml_actions[action_id]
	wesnoth.wml_actions[action_id] = function(cfg)
		if wesnoth.is_skipping_messages() then
			wprintf(W_INFO, "Ignoring [%s] while skipping [message]", action_id)
			return
		end

		_WA_skip_actions[action_id](cfg)
	end
end
