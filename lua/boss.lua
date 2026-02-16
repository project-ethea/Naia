--
-- Naia boss utilities
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local BOSS_TITLE_COLOR = { 255, 147, 40 }
local BOSS_TITLE_SIZE = 22
local BOSS_TITLE_OFFSET = 10

local BOSS_SUBTITLE_COLOR = { 215, 215, 215 }
local BOSS_SUBTITLE_SIZE = 14
local BOSS_SUBTITLE_OFFSET = BOSS_TITLE_OFFSET + 30

local BOSS_BAR_FILL_COLOR = '#ffb367'
local BOSS_BAR_BG_COLOR = '#0a2233'
local BOSS_BAR_FADE_TIME = 1000
local BOSS_BAR_FADE_DELAY = 1500
local BOSS_BAR_SIZE = 10
local BOSS_BAR_OFFSET = BOSS_SUBTITLE_OFFSET + 22

local BOSS_ALERT_SIZE = 32
local BOSS_ALERT_OFFSET = -200
local BOSS_ALERT_DURATION = 3000
local BOSS_ALERT_FADE_TIME = 1000

local BOSS_UI_TABLE = "__naia_boss_ui"

local function verify_gamestate()
	if wml.variables[BOSS_UI_TABLE] == nil then
		-- Create the table and the mandatory attribute under it.
		-- (This is probably going to take place during preload due to the main
		-- event handler hook)
		wml.variables[BOSS_UI_TABLE] = {
			id = "none",
			title = nil,
			subtitle = nil,
			auto_manage = true,
		}
	end
end

local boss_state = {}

setmetatable(boss_state, {
	["__index"] = function(t, k)
		verify_gamestate()

		-- Retrieve unit or nil
		if k == "unit" then
			local boss_id = wml.variables[("%s.id"):format(BOSS_UI_TABLE)]

			if boss_id == "none" then
				return nil
			end

			return wesnoth.units.get(boss_id)
		end

		return wml.variables[("%s.%s"):format(BOSS_UI_TABLE, k)]
	end,
	["__newindex"] = function(t, k, v)
		verify_gamestate()

		-- Set unit id (does not need to refer to a presently extant unit)
		if k == "unit" then
			local boss_id = "none"

			if v ~= nil then
				boss_id = v
			end

			k = "id"
		end

		wml.variables[("%s.%s"):format(BOSS_UI_TABLE, k)] = v
	end
})

--
-- Helper class used to manage individual instances of text overlays used to
-- create the boss bar UI in Wesnoth 1.18, since more than one of those need
-- to be wrangled around together.
--
local BossUiElement = {}
BossUiElement.__index = BossUiElement

function BossUiElement:new(text, offset, options)
	local o = {}
	setmetatable(o, self)

	o.text    = text
	o.offset  = offset
	o.options = options
	o.obj_    = nil

	return o
end

--
-- Refreshes the text overlay on the screen if it already exists, or sets it
-- up for the first time if it doesn't.
--
-- If self_destruct is true, then the overlay disappears after a delay.
--
function BossUiElement:update(self_destruct)
	-- Enforce shared options
	self.options.duration = "unlimited"
	self.options.halign = "center"
	self.options.valign = "top"
	self.options.location = { 0, self.offset }

	if self_destruct then
		self.options.duration = BOSS_BAR_FADE_DELAY
		self.options.fade_time = BOSS_BAR_FADE_TIME
	end

	local text = self.text or ""

	if self.obj_ then
		--self.obj_:replace(text, self.options)
		-- FIXME: Broken in Wesnoth 1.18 - the replace method seems incorrectly
		-- implemented and causes an error message due to sharing code with
		-- add_overlay_text() but seemingly not properly checking which usage
		-- is relevant for the current call:
		--
		-- > calling 'replace' on bad self (translatable string expected, got userdata)
		--
		-- For now we instead do things by hand. The attempted implementation
		-- in the engine would do the same as ours anyway (new handle and all)
		-- so we would gain exactly nothing by using replace().
		self.obj_:remove(0)
	end

	self.obj_ = wesnoth.interface.add_overlay_text(text, self.options)

	if self_destruct then
		-- Self-dispose so we don't get confused later.
		self.obj_ = nil
	end
end

--
-- Removes the text overlay from the screen.
--
function BossUiElement:remove()
	if not self.obj_ then
		return
	end

	self.obj_:remove(BOSS_BAR_FADE_TIME)
	self.obj_ = nil
end

-- We use three separate overlays because the game mysteriously fails to
-- render labels using more complex markup as of 1.18.3. Additionally, all
-- text is left-aligned currently, which would look odd unless we went out of
-- our way to anchor the UI on the left or right instead of having it sit at
-- the center of the screen.
local ui = {
	active   = false,

	title    = nil,
	subtitle = nil,
	bar      = nil,
}

-- U+2588 FULL BLOCK
local FULL_BLOCK = '█'
local EMPTY_BLOCK = FULL_BLOCK
local BAR_LENGTH = 60

local function bar_factory(current, max)
	local bar = ""
	local cnt = math.ceil(BAR_LENGTH * math.max(0, current) / math.max(1, max))
	local rem = BAR_LENGTH - cnt

	if cnt > 0 then
		bar = bar .. ("<span color='%s' rise='2pt'>%s</span>"):format(
			BOSS_BAR_FILL_COLOR,
			string.rep(FULL_BLOCK, cnt))
	end
	if rem > 0 then
		bar = bar .. ("<span color='%s' rise='2pt'>%s</span>"):format(
			BOSS_BAR_BG_COLOR,
			string.rep(EMPTY_BLOCK, rem))
	end

	return bar
end

-- Sets up or refreshes all UI elements
function ui.update()
	local unit = boss_state.unit

	if unit == nil then
		ui.remove()
		return
	end

	-- We have a boss, reinitialize or update the UI display

	wprintf(W_INFO, "refreshing boss fight UI")

	local name, sub = boss_state.title, ("– %s –"):format(boss_state.subtitle)
	local hp, max_hp = unit.hitpoints, unit.max_hitpoints
	local padding = string.rep(" ", #(("%d / %d"):format(hp, max_hp)))
	local bar = ("<b><span size='125%%'>%s</span>  %s  <span size='125%%' color='#d7d7d7'>%d / %d</span></b>"):format(padding, bar_factory(hp, max_hp), hp, max_hp)

	if not ui.title then
		ui.title = BossUiElement:new(name, BOSS_TITLE_OFFSET, {
			color = BOSS_TITLE_COLOR,
			size = BOSS_TITLE_SIZE
		})
	else
		ui.title.text = name
	end

	if not ui.subtitle then
		ui.subtitle = BossUiElement:new(sub, BOSS_SUBTITLE_OFFSET, {
			color = BOSS_SUBTITLE_COLOR,
			size = BOSS_SUBTITLE_SIZE
		})
	else
		ui.subtitle.text = sub
	end

	if not ui.bar then
		ui.bar = BossUiElement:new(bar, BOSS_BAR_OFFSET, {
			size = BOSS_BAR_SIZE
		})
	else
		ui.bar.text = bar
	end

	local temporary = unit.hitpoints < 1 and boss_state.auto_manage

	ui.title:update(temporary)
	ui.subtitle:update(temporary)
	ui.bar:update(temporary)

	if temporary then
		ui.title = nil
		ui.subtitle = nil
		ui.bar = nil
		boss_state.unit = "none"
	end
end

-- Removes all UI elements
function ui.remove()
	if ui.title then
		ui.title:remove()
		ui.title = nil
	end

	if ui.subtitle then
		ui.subtitle:remove()
		ui.subtitle = nil
	end

	if ui.bar then
		ui.bar:remove()
		ui.bar = nil
	end
end

--
-- Displays a floating UI at the top of the game board displaying the specified
-- "boss unit" including its name, subtitle, and current health.
--
-- Usage:
--
-- [boss_ui]
--     # unit id of the boss unit to monitor, or "none" to stop monitoring
--     id=
--     # boss name or title displayed as a caption in large text
--     name=
--     # subtitle displayed underneath the main caption
--     subtitle=
--     # whether to automatically stop monitoring if the unit's HP drops below
--     # 1, which may cause problems with certain cutscenes where this is an
--     # intended course of action
--     auto_manage=true
-- [/boss_ui]
--
-- [boss_ui]
--     # stops monitoring, same as id="none"
--     remove=yes
-- [/boss_ui]
--
-- The boss bar works as follows:
--
-- * Whenever the game preload event fires, it checks for a boss. If one is
--   found, the bar is displayed.
-- * When code spawns a boss, it summons the boss bar and assigns the boss
--   unit id for the next preload event.
-- * When the boss 'die' event is dispatched, the boss unit id is automatically
--   cleared. It can also be cleared via API request. In both cases, the bar is
--   immediately removed from display.
-- * Naia constantly polls the boss HP during attack events to ensure the bar
--   is updated as soon as possible.
--
function wesnoth.wml_actions.boss_ui(cfg)
	local unit_id = cfg.id

	if cfg.remove then
		unit_id = "none"
	end

	if unit_id == nil then
		wml.error("[boss_ui]: Must specify a boss unit id")
	end

	if cfg.auto_manage == nil then
		boss_state.auto_manage = true
	else
		boss_state.auto_manage = not not cfg.auto_manage
	end

	-- FIXME: test only, should error
	boss_state.title = cfg.name or _ "Chaos Warlord"
	boss_state.subtitle = cfg.subtitle or _ "The Fire of Uria"

	boss_state.unit = cfg.id

	wprintf(W_INFO, "set boss unit id to %s (present: %s)", cfg.id, not not boss_state.unit)

	-- May silently fail for now if the unit does not exist
	ui.update()
end

--
-- Displays the boss warning text.
--
function wesnoth.wml_actions.boss_popup()
	local banner = _ "Enemy boss sighted!"

	wesnoth.interface.add_overlay_text(("<b>%s</b>"):format(banner), {
		color = BOSS_TITLE_COLOR,
		size = BOSS_ALERT_SIZE,
		location = { 0, BOSS_ALERT_OFFSET },
		duration = BOSS_ALERT_DURATION,
		fade_time = BOSS_ALERT_FADE_TIME
	})
end

-- We hook into preload to ensure the boss UI is persistent between reload
-- cycles whenever it's supposed to be active.

local HOOK_EVENTS = "preload,turn refresh,unit placed,last breath,die"

if WESNOTH_VERSION > V"1.19.2" then
	HOOK_EVENTS = HOOK_EVENTS .. ",unit hits"
else
	HOOK_EVENTS = HOOK_EVENTS .. ",attacker hits,defender hits"
end

on_event(HOOK_EVENTS, ui.update)
