--
-- Persistent WML variables library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2012 - 2023 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

local PERSISTENT_NS_NAIA = "Project_Ethea.Naia"

local PERSISTENT_GTABLE = "global_table"
local GTABLE            = "__naia_gtable"

local function gtable_get(key)
	return wml.variables[("%s.%s"):format(GTABLE, key)]
end

local function gtable_set(key, value)
	wml.variables[("%s.%s"):format(GTABLE, key)] = value
end

function wesnoth.wml_actions.global_table(cfg)
	local namespace = cfg.namespace or PERSISTENT_NS_NAIA

	wprintf(W_DBG, "open gtable from ns '%s'", namespace)

	-- Open global table

	wesnoth.wml_actions.get_global_variable {
		namespace   = namespace,
		from_global = PERSISTENT_GTABLE,
		to_local    = GTABLE,
	}

	-- Force the global table to exist if this is a fresh persistent store

	if type(wml.variables[GTABLE]) ~= "table" then
		wml.variables[GTABLE] = nil
		wml.variables[GTABLE] = {}
	end

	gtable_set("_gtable_start", 1)

	--wesnoth.wml_actions.inspect {}

	-- Perform global table actions

	local cmds = wml.shallow_literal(cfg)

	for i = 1, #cmds do
		local t = cmds[i]
		local cmd_id = t[1]
		local cmd_cfg = t[2]

		local key = cmd_cfg.key or wml.error("[global_table] Missing required key= attribute in subcommand")

		if cmd_id == "read" then
			wprintf(W_DBG, " * gtable read %s", key)
			wml.variables[key] = gtable_get(key)
		elseif cmd_id == "write" then
			wprintf(W_DBG, " * gtable write %s", key)
			gtable_set(key, wml.variables[key])
		elseif cmd_id == "delete" then
			wprintf(W_DBG, " * gtable delete %s", key)
			gtable_set(key, nil)
		else
			wml.error(("[global_table] Unrecognized command '%s'"):format(cmd_id))
		end
	end

	-- Flush and close global table

	wprintf(W_DBG, "close gtable")

	wesnoth.wml_actions.set_global_variable {
		namespace  = namespace,
		to_global  = PERSISTENT_GTABLE,
		from_local = GTABLE,
		immediate  = true,
	}

	wml.variables[GTABLE] = nil
end
