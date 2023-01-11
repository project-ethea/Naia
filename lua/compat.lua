--
-- Add-on version status check library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2006 - 2023 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local deferred_executes = {}

function wesnoth.wml_actions.naia__deferred_unsynced_execute()
	for i, func in ipairs(deferred_executes) do
		wesnoth.sync.run_unsynced(func)
	end
end

--
-- Used to defer execution of GUI code to preload to avoid issues
--
local function defer(func)
	table.insert(deferred_executes, func)
	wesnoth.add_event_handler {
		id   = "naia:deferred_execute",
		name = "preload",
		wml.tag.naia__deferred_unsynced_execute {},
	}
end

local function do_compat_fail(msg, may_ignore, silent_in_maintainer_mode, feedback_mode)
	if naia_is_in_maintainer_mode() then
		wprintf(W_WARN, "COMPAT: Version/configuration issue in maintainer mode: %s", msg)

		if silent_in_maintainer_mode then
			return
		end
	end

	defer(function()
		wesnoth.wml_actions.bug {
			message       = msg,
			should_report = (feedback_mode ~= nil),
			may_ignore    = (naia_is_in_maintainer_mode() or may_ignore),
			feedback      = feedback_mode,
		}
	end)
end

local function do_host_minimum_version_unmet(host_min, host_max)
	local msg = _ "This version of %s requires Wesnoth %s – %s and will not run on previous versions."
	msg = tostring(msg):format(naia_get_package_i18n_name(), host_min, host_max)
	do_compat_fail(msg)
end

local function do_host_maximum_version_number_unmet(host_min, host_max)
	local msg = _ "This version of %s requires Wesnoth %s – %s. Support for later versions is incomplete or untested, and there may be broken functionality. If you choose to continue, you are doing so at your own risk."
	msg = tostring(msg):format(naia_get_package_i18n_name(), host_min, host_max)
	do_compat_fail(msg, true)
end

local function do_host_blacklisted_version(host_bl_version, host_min, host_max)
	local msg = _ "This version of %s is not compatible with Wesnoth %s. You must use a different version in the %s – %s range."
	msg = tostring(msg):format(naia_get_package_i18n_name(), host_bl_version, host_min, host_max)
	do_compat_fail(msg)
end

local function do_experimental_port_notice(host_ver)
	local msg = _ "This is an experimental port of %s to Wesnoth %s.\nIf you choose to continue, you must report any issues to the author on the project’s issue tracker:"
	msg = tostring(msg):format(naia_get_package_i18n_name(), host_ver)
	do_compat_fail(msg, true, true, "omgbugseverywhere")
end

local function do_addon_compat_fail(titles)
	local msg, caption

	if #titles == 1 then
		caption = _ "Incompatible Add-on"
		msg = _ "The following add-on is incompatible with %s and must be removed before continuing:"
	else
		caption = _ "Incompatible Add-ons"
		msg = _ "The following add-ons are incompatible with %s and must be removed before continuing:"
	end

	msg = tostring(msg):format(naia_get_package_i18n_name()) .. "\n\n"

	for i, title in ipairs(titles) do
		-- U+2022 BULLET
		msg = msg .. "    • " .. title .. "\n"
	end

	defer(function ()
		gui.show_prompt(caption, msg)
		die()
	end)
end

--
-- The following add-ons are known to case balancing issues with Project Ethea
-- campaigns or break boss fights and scripted cutscenes.
--

local naia_addons_bl = {
	[ "Damage_Distribution_Mod" ]				= "Randomized Damage Mod",
	[ "Move_Units_Between_Campaigns" ]			= "Move Units Between Campaigns",
	[ "No_Randomness_Mod" ]						= "No Randomness Mod",
}

function check_host_compatibility(host_min, host_max, host_blacklist, is_experimental_port)
	if WESNOTH_VERSION < V(host_min) then
		do_host_minimum_version_unmet(host_min, host_max)
		return
	end

	if WESNOTH_VERSION > V(host_max) then
		do_host_maximum_version_number_unmet(host_min, host_max)
		return
	end

	if host_blacklist == nil then
		host_blacklist = {}
	end

	for i, host_bad in ipairs(host_blacklist) do
		if WESNOTH_VERSION == V(host_bad) then
			do_host_blacklisted_version(host_bad, host_min, host_max)
			return
		end
	end

	if is_experimental_port then
		do_experimental_port_notice(host_max)
	end
end

function check_addon_compatibility(package_blacklist)
	local bl_found = {}

	local function do_single_addon_compat(id, title)
		wprintf(W_INFO, "COMPAT: Checking for add-on %s...", id)
		if filesystem.have_file("~add-ons/" .. id) then
			wprintf(W_ERR, "COMPAT: Incompatible add-on %s detected", id)
			table.insert(bl_found, title)
		end
	end

	if package_blacklist == nil then
		package_blacklist = {}
	end

	for id, title in pairs(naia_addons_bl) do
		do_single_addon_compat(id, title)
	end

	for id, title in pairs(package_blacklist) do
		do_single_addon_compat(id, title)
	end

	if #bl_found > 0 then
		table.sort(bl_found, function(a, b) return a < b end)
		wprintf(W_ERR, "COMPAT: %d incompatible add-ons found, cannot continue", #bl_found)
		do_addon_compat_fail(bl_found) -- does not return
	end

	wprintf(W_INFO, "COMPAT: Add-on compatibility check finished!")
end
