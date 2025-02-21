--
-- Wesnoth Journey Log module (back-end)
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2024 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

journeylog = {}

JOURNEYLOG_TABLE = "__naia_journeylog"

local journeylog_campaign_info = {}

function jprintf(lvl, msg, ...)
	wprintf(lvl, "JourneyLog: " .. msg, ...)
end

-- Ensure the JourneyLog table is initialised when starting a scenario. It is
-- harmless to allow this to run on each reload, plus has the added benefit of
-- updating the campaign or scenario name translatables if they have changed.
on_event("preload", function()
	wml.variables[("%s.%s.name"):format(JOURNEYLOG_TABLE, wesnoth.scenario.campaign.id)] = wesnoth.scenario.campaign.name
	wml.variables[("%s.%s.%s.name"):format(JOURNEYLOG_TABLE, wesnoth.scenario.campaign.id, wesnoth.scenario.id)] = wesnoth.scenario.name
end)

--
-- Registers the specified campaign.
--
-- If mnemonic or label are not proivded, they will be copied from the current
-- campaign if its id matches campaign_id.
--
-- Arguments:
--
--   campaign_id             This is the campaign's internal identifier.
--   label                   This is the campaign's user-friendly name used in
--                           the user interface.
--   mnemonic                This is the campaign's abbreviation/mnemonic.
--
function journeylog.register_campaign(campaign_id, label, mnemonic)
	if journeylog_campaign_info[campaign_id] ~= nil then
		-- Already registered
		return
	end

	local baseline = {
		abbreviation = nil,
		name = nil
	}

	if wesnoth.scenario.campaign ~= nil and wesnoth.scenario.campaign.id == campaign_id then
		baseline = wesnoth.scenario.campaign
	end

	local entry = {
		mnemonic = mnemonic or baseline.abbrev,
		label    = label or baseline.name,
	}

	if not entry.mnemonic or not entry.label then
		jprintf(W_ERR, "incomplete data for campaign '%s' which is not the current campaign", campaign_id)
	end

	journeylog_campaign_info[campaign_id] = entry

	jprintf(W_DBG, "registered campaign %s (mnemonic: %s, label: '%s')", campaign_id, entry.mnemonic, entry.label)
end

--
-- Registers the specified scenario.
--
-- Arguments:
--
--   campaign_id             This is the parent campaign's internal identifier.
--                           If nil, the current campaign's id is used if
--                           available.
--   scenario_id             This is the scenario's internal identifier.
--   label                   This is the scenarios's regular user-friendly name
--                           seen in most user interfaces as well as save
--                           files.
--   mnemonic                This is the scenario's abbreviation/mnemonic used
--                           in certain user interfaces.
--   hidden                  Specifies whether the scenario should be hidden
--                           from listings in the JourneyLog user interface.
--                           Use this for cutscene and technical scenarios.
--
function journeylog.register_scenario(campaign_id, scenario_id, label, mnemonic, hidden)
	local real_cid = campaign_id

	if not real_cid then
		if not wesnoth.scenario.campaign then
			wml.error("journeylog.register_scenario(): No campaign id provided and not running in a campaign scenario context")
		end

		real_cid = wesnoth.scenario.campaign.id
	end

	journeylog.register_campaign(real_cid)

	journeylog_campaign_info[real_cid][scenario_id] = {
		mnemonic = mnemonic,
		label    = label,
		hidden   = hidden
	}

	jprintf(W_DBG, "registered scenario %s (mnemonic: %s, label: '%s', hidden: %s)", scenario_id, mnemonic, label, tostring(hidden))
end

--
-- Scenario initialization-time wrapper for journeylog.register_scenario.
--
-- WML arguments:
--
--   id                      This is the scenario's internal identifier.
--   name                    This is the scenarios's regular user-friendly name
--                           seen in most user interfaces as well as save
--                           files.
--   abbrev                  This is the scenario's abbreviation/mnemonic used
--                           in certain user interfaces.
--   hidden                  Specifies whether the scenario should be hidden
--                           from listings in the JourneyLog user interface.
--                           Use this for cutscene and technical scenarios.
--
function journeylog.register_scenario_wml(wml_args)
	journeylog.register_scenario(nil, wml_args.id, wml_args.title, wml_args.abbrev, wml_args.hidden)
end

function journeylog.register_campaign_mnemonic(campaign_id, mnemonic)
	journeylog_campaign_mn[campaign_id] = mnemonic
end

local function journeylog_var_init()
	local entry_path = ("%s.%s.%s.%s"):format(JOURNEYLOG_TABLE, wesnoth.scenario.campaign.id, wesnoth.scenario.id, event_context_id())
	return entry_path
end

local function _enumerate_impl_common(wml_container)
	local enum = {}

	for i, cfg in ipairs(wml_container) do
		table.insert(enum, {
			-- index 1 holds the WML child's tag name
			id = cfg[1],
			-- .name has a user-friendly name per convention
			name = cfg[2].name or cfg[1]
		})
	end

	return enum
end

function journeylog.enumerate_campaigns()
	local journeylog_table = wml.variables[JOURNEYLOG_TABLE]
	return _enumerate_impl_common(journeylog_table)
end

function journeylog.enumerate_scenarios(campaign_id)
	local scenario_table = wml.variables[("%s.%s"):format(JOURNEYLOG_TABLE, campaign_id)]
	return _enumerate_impl_common(scenario_table)
end

function journeylog.read_scenario(campaign_id, scenario_id)
	local var_path = ("%s.%s.%s"):format(JOURNEYLOG_TABLE, campaign_id, scenario_id)
	local scenario_ct = wml.variables[var_path]

	if not scenario_ct then
		jprintf(W_ERR, "requested unrecorded campaign or scenario %s.%s", campaign_id, scenario_id)
		return nil
	end

	local scenario_log = {}

	-- We split the scenario log into groups for each event handler. We assume
	-- that messages from event handlers with identical context hashes should
	-- be grouped together as if they were part of a single sequence.

	for i, cfg in ipairs(scenario_ct) do
		local messages = {}
		local event_hash = cfg[1]

		jprintf(W_DBG, "reading messages in %s.%s event %s", campaign_id, scenario_id, event_hash)

		for message in wml.child_range(cfg[2], "message") do
			-- Just copy the WML contents, we don't do anything fancier here
			-- (yet).
			table.insert(messages, {
				is_narrator = message.is_narrator,
				speaker = message.speaker,
				message = message.message,
				image = message.image,
				choice = message.choice,
			})
		end

		table.insert(scenario_log, messages)
	end

	return scenario_log
end

local function journeylog_record_message(params_cfg, choice_text)
	local event_path = journeylog_var_init()
	local recorded_num = wml.variables[event_path .. ".message.length"] or 0

	local record_path = ("%s.message[%d]"):format(event_path, recorded_num)

	-- Stamp the event name into the message block for use by the UI
	if not wml.variables[event_path] then
		wml.variables[event_path] = { event_name = wesnoth.current.event_context.name }
	end

	wml.variables[record_path] = {
		is_narrator = not params_cfg.title or nil,
		speaker = params_cfg.title,
		message = params_cfg.message,
		image = params_cfg.portrait,
		choice = choice_text,
	}
end

--
-- Wesnoth engine call hooks
--

local ENG_gui_show_narration = gui.show_narration
local ENG_wesnoth_interface_is_skipping_messages = wesnoth.interface.is_skipping_messages

jprintf(W_DBG, "hook wesnoth.interface.is_skipping_messages")
wesnoth.interface.is_skipping_messages = function(i_am_naia)
	-- We pretend the user is never skipping messages when called by functions
	-- outside JourneyLog so that we can always capture the message that would
	-- be shown by gui.show_narration for safekeeping. The only exception is
	-- Naia, which needs to query the actual skipping state in order to adjust
	-- the behaviour of various functions including visual effects.
	if i_am_naia ~= 0x4149414E then
		--jprintf(W_DBG, "foreign code queried user skip, lying and saying no")
		return false
	end

	-- Secret handshake from Naia!
	--jprintf(W_DBG, "Naia queried user skip")
	return ENG_wesnoth_interface_is_skipping_messages()
end

jprintf(W_DBG, "hook gui.show_narration")
gui.show_narration = function(msg_cfg, options, text_input)
	jprintf(W_DBG, "in substitute gui.show_narration()")

	local res, user_text = -1, nil

	if not ENG_wesnoth_interface_is_skipping_messages() or text_input ~= nil or #options > 0 then
		jprintf(W_DBG, "jumping to engine to display [message]")
		-- We capture the engine's results since these will be used by our caller to
		-- act upon the user's choice, including enabling skip mode. If user input is
		-- involved, we need to record it in JourneyLog as well.
		res, user_text = ENG_gui_show_narration(msg_cfg, options, text_input)
	else
		jprintf(W_DBG, "skipping UI display of [message] due to user skip")
	end

	if user_text ~= nil then
		journeylog_record_message(msg_cfg, user_text)
	elseif #options > 0 and res > 0 then
		journeylog_record_message(msg_cfg, options[res].label)
	else
		journeylog_record_message(msg_cfg)
	end

	return res, user_text
end
