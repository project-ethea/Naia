--
-- WML conditional expressions library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2020 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

function wesnoth.wml_conditionals.position_equals(cfg)
	local var_id = cfg.variable or helper.wml_error("[position_equals] Missing required variable= attribute")
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
	local var_id = cfg.name or helper.wml_error("[variable_in] Missing required name= attribute")
	local values = cfg.values or helper.wml_error("[variable_in] Missing required values= attribute")

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
