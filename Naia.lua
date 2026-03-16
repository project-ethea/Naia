--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

-------------------------------------------------------------------------------
--                              COMMON LIBRARY                               --
-------------------------------------------------------------------------------

PROJECT_ETHEA_NAIA_VERSION = (...).version
NAIA_PREFIX                = (...).prefix
WESNOTH_VERSION            = wesnoth.current_version()
WML_INIT                   = wml.get_child(..., "init")

utils                      = wesnoth.require("wml-utils.lua")
on_event                   = wesnoth.require("on_event.lua")

---
-- Log levels for wput and wprintf.
---

W_ERR  = 1 -- Error.
W_WARN = 2 -- Warning (default maximum log level).
W_INFO = 3 -- Info.
W_DBG  = 4 -- Debug.

local loglvl_map = { "error", "warning", "info", "debug" }

local logprefix = "[Naia] "

local logdepth = 0

function _wsetlogprefix(str)
	logprefix = "[" .. str .. "] "
end

function _windentprefix()
	return string.rep(" ", logdepth * 2)
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
		message = logprefix .. _windentprefix() .. tostring(msg)
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
-- Increases the log indentation level.
---
function windent()
	logdepth = logdepth + 1
end

---
-- Decreases the log indentation level.
---
function wunindent()
	logdepth = math.max(0, logdepth - 1)
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
-- Returns the line count for the specified (potentially translatable) string.
---
function line_count(text)
	local lines, sz = 1, tostring(text)
	for lf in sz:gmatch("\x0a") do -- rip Mac OS 9 users lololol
		lines = lines + 1
	end
	return lines
end

---
-- Returns a value restricted to a range [minval, maxval].
---
function in_range(value, minval, maxval)
	return math.max(minval, math.min(value, maxval))
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

--
-- Provides a string representation of a map location object.
--
function loc2str(loc)
	if loc.x ~= nil and loc.y ~= nil then
		return string.format("(%d,%d)", loc.x, loc.y)
	end
	if loc[1] ~= nil and loc[2] ~= nil then
		return string.format("(%d,%d)", loc[1], loc[2])
	end
	return "<invalid>"
end

---
-- Converts a string to a table of bytes.
--
-- WARNING: This is a table of BYTES, not CHARACTERS. This function is not
-- Unicode-safe.
---
function str2table(str)
	local tbl = {}
	tostring(str):gsub(".", function(ch) table.insert(tbl, ch) end)
	return tbl
end

---
-- Returns a random character from a collection.
--
-- WARNING:This does NOT use a synchronized RNG call. You need to synchronize
-- the result manually yourself.
--
-- WARNING 2: This function is not Unicode-safe. If str contains multibyte
-- characters you're screwed.
---
function random_char_unsynced(str)
	local i = math.random(1, str:len())
	return str:sub(i, i)
end

function list_has(table_v, wanted_value)
	if table_v == nil then
		return false
	end

	for _, value in ipairs(table_v) do
		if value == wanted_value then
			return true
		end
	end

	return false
end

---
-- Returns the size of a table.
---
function table_size(table_v, include_nil)
	local n = 0
	for val in pairs(table_v) do
		if val ~= nil or include_nil == true then
			n = n + 1
		end
	end
	return n
end

---
-- Returns whether a table is empty or not.
---
function table_empty(table_v, include_nil)
	for val in pairs(table_v) do
		if val ~= nil or include_nil == true then
			return false
		end
	end

	return true
end

---
-- Returns a sorted list of keys for a table.
---
function table_keys(table_v)
	local keys = {}
	for key, v in pairs(table_v) do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

---
-- Returns a table that contains the elements of both tables.
--
-- If table_b has items with the same keys as those of table_a then they will
-- overwrite the latter's items in the result table.
---
function table_merge(table_a, table_b)
	local keys_a, keys_b = table_keys(table_a), table_keys(table_b)
	local result = {}

	for _, key in ipairs(keys_a) do
		result[key] = table_a[key]
	end

	for _, key in ipairs(keys_b) do
		result[key] = table_b[key]
	end

	return result
end

---
-- Returns an array that contains the union of both tables.
--
-- This forces the result to have numeric indices. Elements from table_a are
-- always followed by elements from table_b.
---
function array_join(table_a, table_b)
	local result = {}

	for _, element in ipairs(table_a) do
		table.insert(result, element)
	end

	for _, element in ipairs(table_b) do
		table.insert(result, element)
	end

	return result
end

---
-- Dumps a table in string form.
---
function table_dump(obj, level)
	if level == nil then
		level = 0
	end

	local str = ""

	local function write_base(text, newline, indent)
		if newline == nil then
			newline = true
		end

		if indent == nil then
			indent = true
		end

		if indent then
			str = str .. string.rep(" ", level * 4)
		end

		str = str .. text

		if newline then
			str = str .. "\n"
		end
	end

	local function put(text)
		write_base(text, true, true)
	end

	local function add(text)
		write_base(text, false, false)
	end

	local function finalize(text)
		write_base(text, true, false)
	end

	local function start(text)
		write_base(text, false, true)
	end

	finalize("{")
	level = level + 1

	for k, v in pairs(obj) do
		if type(k) == "number" then
			start(("[%d] = "):format(k))
		elseif type(k) == "string" then
			start(("\"%s\" = "):format(k))
		else
			start(("<%s key> = "):format(type(k)))
		end

		if type(v) == "number" then
			finalize(("%d"):format(v))
		elseif type(v) == "string" then
			finalize(("\"%s\""):format(v))
		elseif type(v) == "table" then
			finalize(("table: %s"):format(table_dump(v, level)))
		else
			finalize(("data: %s"):format(tostring(v)))
		end
	end

	level = level - 1
	put("}")

	return str
end

---
-- Returns to the titlescreen ASAP.
---
function die()
	local endlevel_config = {
		result           = "defeat",
		linger_mode      = false,
		carryover_report = false
	}

	-- Because of some stupid 1.14 behaviour change/bug, firing endlevel
	-- before prestart results in the player's victory and instant
	-- completion of the whole campaign. Injecting a preload event to run
	-- endlevel after the storyscreen works.
	if wesnoth.current.event_context.name == "_from_lua" then
		wput(W_DBG, "deferred die() on global [lua] context")
		on_event("preload", function()
			wesnoth.wml_actions.endlevel(endlevel_config)
		end)
	else
		wput(W_DBG, "die() on event context")
		wesnoth.wml_actions.endlevel(endlevel_config)
	end
end

---
-- Helper used for injecting global events (see /core/events.cfg).
---

function global_run_wml(cfg)
	local evtcount = wml.child_count(cfg, "event")
	local wmicount = wml.child_count(cfg, "set_menu_item")

	wprintf(W_INFO, "Running global events block (%d events, %d menu items)", evtcount, wmicount)

	utils.handle_event_commands(cfg)
end

---
-- Wrapper around wesnoth.version (e.g. `V"1.14.0"` or `V(some_var)`).
-- 1.2.3.x becomes 1.2.3.9999.
---
function V(version_number)
	if tostring(version_number):match('%.x$') ~= nil then
		version_number = tostring(version_number):gsub('x$', '9999')
	end

	return wesnoth.version(version_number)
end

local function evctx_id_cleanname(name)
	return name:gsub("[^0-9A-Za-z]", "")
end

--
-- Generates a "hash" of an event context that can be used to identify it in
-- an opaque yet WML-friendly fashion.
--
function event_context_id()
	local hash = ""
	local ctx = wesnoth.current.event_context

	-- The resulting "hash" can only contain characters which are valid in WML
	-- identifiers, which limits our universe considerably.
	--
	-- A full hash will look like this, with elements which are empty or zero
	-- being omitted from the output:
	--
	--   N<event dispatch name><trail>
	--   I<event handler id><trail>
	--   X<x1>Y<y1>
	--   U<x2>V<y2>
	--
	-- For the event name and id, the <trail> component is the total count of
	-- whitespace or underscore characters, which are removed from the
	-- identifier since: a) underscore and whitespace are considered equivalent
	-- in event dispatch names; b) whitespace is illegal in WML identifiers.

	local id, id_trail = evctx_id_cleanname(ctx.id)
	local name, name_trail = evctx_id_cleanname(ctx.name)

	if id and id ~= "" then
		hash = ("N%s%dI%s%d"):format(name, name_trail, id, id_trail)
	else
		hash = ("N%s%d"):format(name, name_trail)
	end

	if ctx.x1 or ctx.y1 then
		hash = hash .. ("X%dY%d"):format(ctx.x1, ctx.y1)
	end

	if ctx.x2 or ctx.y2 then
		hash = hash .. ("U%dV%d"):format(ctx.x2, ctx.y2)
	end

	return hash
end

-------------------------------------------------------------------------------
--                              INITIALIZATION                               --
-------------------------------------------------------------------------------

local NAIA_PACKAGES = {
	'package',
	'common',
	'abilities',
	'achievements',
	'boss',
	'conditional',
	'hmu',
	'journey/core',
	'journey/log',
	'journey/lore',
	'journey/milestones',
	'journey/achievements',
	'npc',
	'optimizations',
	'patch',
	'persistent',
	'spawner',
	'theme',
	'units',
	'visualfx',
	'wlp',
	'gui/utils',
	'gui/amla_list',
	'gui/bug',
	'gui/campaign_intro',
	'gui/debug_utilities',
	'gui/gameplay_notification',
	'gui/horizontal_choice',
	'gui/journey_ui',
	'gui/journey_ui_extra',
	'gui/item_prompt',
	'gui/transient_message',
	'gui/widgets',
	'compat',
}

wprintf(W_INFO, "codename Naia version %s initializing", PROJECT_ETHEA_NAIA_VERSION)

for _, pkg in ipairs(NAIA_PACKAGES) do
	local path = ("%s/lua/%s.lua"):format(NAIA_PREFIX, pkg)
	wprintf(W_INFO, "Init: loading %s", path)
	windent()
	wesnoth.dofile(path)
	wunindent()
end

if WML_INIT then
	-- wmlinit block is executed as a part of a pre-preload WML event
	wprintf(W_INFO, "Init: execute WML startup block")
	utils.handle_event_commands(WML_INIT)
end

wprintf(W_INFO, "Init: Naia initialization complete")
