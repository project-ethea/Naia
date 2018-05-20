--
-- Lua core utilities library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2018 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

---
-- TODO: use utils.split() on 1.13.x instead
---
function split(s)
	return tostring(s):gmatch("[^%s,][^,]*")
end

---
-- Returns a pseudorandom value from a set without syncing replays/MP.
--
-- This will use the same format as WML [set_variable] in the future, maybe,
-- but for now it's just a trivial wrapper around math.random with the added
-- requirement of providing both arguments.
--
-- Do NOT use this for gamestate-altering actions. You've been warned.
---
function unsynced_random(a, b)
	return math.random(a, b)
end

---
-- Log levels for wput and wprintf.
---

W_ERR  = 1 -- Error.
W_WARN = 2 -- Warning (default maximum log level).
W_INFO = 3 -- Info.
W_DBG  = 4 -- Debug.

local loglvl_map = { "error", "warning", "info", "debug" }

local logprefix = "[Naia] "

function _wsetlogprefix(str)
	logprefix = "[" .. str .. "] "
end

---
-- Prints a text line using the engine log facilities.
--
-- lvl: One of W_ERR, W_WARN, W_INFO, or W_DBG.
-- msg: Line contents.
---
function wput(lvl, msg)
	wesnoth.wml_actions.wml_message {
		logger = loglvl_map[math.max(1, math.min(lvl, #loglvl_map))],
		message = logprefix .. tostring(msg)
	}
end

---
-- Prints a formatted (printf-style) line using the engine log facilities.
--
-- lvl: One of W_ERR, W_WARN, W_INFO, or W_DBG.
-- fmt: Line format specification.
-- ...: Parameters for line formatting.
---
function wprintf(lvl, fmt, ...)
	wput(lvl, tostring(fmt):format(...))
end

---
-- Returns a textdomain-specific string translated to the current locale
--
-- Note that this is only intended to be used with mainline textdomains. For
-- add-on textdomains the _ hack including comments with fake WML is still
-- needed so that wmlxgettext can catch and add the new strings.
---
function wgettext(str, domain)
	if domain == nil then
		domain = "wesnoth"
	end

	return wesnoth.textdomain(domain)(str)
end

---
-- Shuffles a table.
--
-- This is helper.shuffle from 1.13.1+dev, backported to 1.12.x sans the RNG
-- function parameter.
---
function safe_shuffle(t)
	local function random_func(a, b)
		return helper.rand(("%d..%d"):format(a, b))
	end
	-- since tables are passed by reference, this is an in-place shuffle
	-- it uses the Fisher-Yates algorithm, also known as Knuth shuffle
	assert( type( t ) == "table", string.format( "helper.shuffle expects a table as parameter, got %s instead", type( t ) ) )
	local length = #t
	for index = length, 2, -1 do
		local random = random_func( 1, index )
		t[index], t[random] = t[random], t[index]
	end
end

---
-- Returns a value restricted to a range [minval, maxval].
---
function in_range(value, minval, maxval)
	return math.max(minval, math.min(value, maxval))
end

---
-- Returns to the titlescreen ASAP.
---
function die()
	-- Because of some stupid 1.14 behaviour change/bug, firing endlevel
	-- before prestart results in the player's victory and instant
	-- completion of the whole campaign. Injecting a preload event to run
	-- endlevel after the storyscreen works.
	if wesnoth.current.event_context.name == "_from_lua" then
		wput(W_DBG, "deferred die() on global [lua] context")
		wesnoth.wml_actions.event {
			name = "preload",
			{ "endlevel", {
				result           = "defeat",
				linger_mode      = false,
				carryover_report = false
			}}
		}
	else
		wput(W_DBG, "die() on event context")
		wesnoth.wml_actions.endlevel {
			result           = "defeat",
			linger_mode      = false,
			carryover_report = false
		}
	end
end

wprintf(W_INFO, "codename Naia version %s initializing", PROJECT_ETHEA_NAIA_VERSION)
