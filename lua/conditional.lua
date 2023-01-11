--
-- WML conditional expressions library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2020 - 2023 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

function wesnoth.wml_conditionals.position_equals(cfg)
	local var_id = cfg.variable or wml.error("[position_equals] Missing required variable= attribute")
	local x = cfg.x or 0
	local y = cfg.y or 0

	local variable = wml.variables[var_id]

	if variable == nil or variable.x == nil or variable.y == nil then
		wprintf(W_WARN, "[position_equals] Variable %s or its .x or .y members do not exist", var_id)
		return false
	end

	return variable.x == x and variable.y == y
end

function wesnoth.wml_conditionals.variable_in(cfg)
	local var_id = cfg.name or wml.error("[variable_in] Missing required name= attribute")
	local values = cfg.values or wml.error("[variable_in] Missing required values= attribute")

	local variable = wml.variables[var_id]

	if variable == nil then
		wprintf(W_WARN, "[variable_in] Variable %s does not exist", var_id)
		return false
	end

	for val in values:gmatch("[^,]+") do
		if variable == val then
			return true
		end
	end

	return false
end

function wesnoth.wml_conditionals.variable_is_even(cfg)
	local var_id = cfg.name or wml.error("[variable_is_even] Missing required name= attribute")
	return tonumber(wml.variables[var_id]) % 2 == 0
end

--
-- Returns whether the first unit matched by a SUF is presently on a location
-- it would be able to move into under normal circumstances. If no unit can be
-- found matching the SUF then it always returns false.
--
-- [unit_location_is_passable]
--     <StandardUnitFilter>
-- [/unit_location_is_passable]
--
function wesnoth.wml_conditionals.unit_location_is_passable(cfg)
	local u = wesnoth.units.find_on_map(cfg)[1]
	return not not (u and u:movement(wesnoth.get_terrain(u.x, u.y)) < u.max_moves)
end
