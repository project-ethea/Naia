--
-- Add-on package description utilities
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2020 - 2021 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local default_package = {
	global_id    = "project_ethea.Naia",
	name         = "<Naia>",
	i18n_name    = "<Naia>", -- intentionally not translatable
	version      = "0.0.0",
	abbreviation = "Naia",
	tracker_url  = "https://github.com/project-ethea/Naia/issues",
	forum_thread = "",
	dev_mode     = false,
	naia_version = PROJECT_ETHEA_NAIA_VERSION,
	registered   = false,
}

local package = default_package

--[[

Registers a Naia add-on, filling in the internal info table with attributes
used by certain functionality.

Usage:

naia_register_package {
    -- The add-on's global id, used e.g. for persistent WML variables.
    global_id    = "project_ethea.After_the_Storm",

    -- The user-visible name for the add-on.
    name         = "After the Storm",

    -- The translatable name for the add-on.
    i18n_name    = wesnoth.textdomain("wesnoth-After_the_Storm")("After the Storm"),

    -- The add-on version.
    version      = "0.10.0",

    -- The user-visible abbreviation for the add-on.
    abbreviation = "AtS",

    -- The issue tracker URL for the add-on.
    tracker_url  = "http://localhost/",

    -- The forum thread URL for the add-on.
    forum_thread = "http://localhost/",

    -- Whether maintainer mode is enabled, which affects the behavior of
    -- certain debug features.
    maintainer_mode = false,
}

]]
function naia_register_package(p)
	if package.registered then
		wput(W_WARN, "multiple calls to naia_register_package() detected!")
		return
	end

	package.global_id = p.global_id or default_package.global_id
	package.name = p.name or default_package.name
	package.i18n_name = p.i18n_name or package.name -- fall back to untranslated name
	package.version = p.version or default_package.version
	package.abbreviation = p.abbreviation or default_package.abbreviation
	package.tracker_url = p.tracker_url or default_package.tracker_url
	package.forum_thread = p.forum_thread or default_package.forum_thread

	if p.maintainer_mode == nil then
		package.dev_mode = default_package.dev_mode
	else
		package.dev_mode = p.maintainer_mode
	end

	package.registered = true

	_wsetlogprefix(package.abbreviation)
	wprintf(W_INFO, "%s (%s) version %s (Naia %s)", package.name, package.global_id, package.version, package.naia_version)

	if package.dev_mode then
		wprintf(W_INFO, "Maintainer mode enabled")
	end
end

function naia_get_package_name()
	return package.name
end

function naia_get_package_i18n_name()
	return tostring(package.i18n_name)
end

function naia_get_package_name_abbrev()
	return package.abbreviation
end

function naia_get_package_version()
	return { package.version, package.naia_version }
end

function naia_get_package_url()
	return { package.forum_thread, package.tracker_url }
end

function naia_get_package_id()
	return package.global_id
end

function naia_is_in_maintainer_mode()
	return package.dev_mode
end
