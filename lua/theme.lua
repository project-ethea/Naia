---
-- Theme UI support API, allowing things such as setting up status icons for
-- custom unit statuses without doing explicit callback and table sorcery.
---

------------------
-- THEME UI API --
------------------

-- Format: [{ id = <str>, icon = <str>, tooltip = <str>, source = <str> }]
local theme_ui_unit_statuses = {}

--
-- The icky implementation part that has to speak the dark tongue of the
-- Theme UI gods from beyond the veil.
--

-- We need to call back to the engine to get its notion of the default status
-- report for a unit (poisoned, slowed, etc.).
local _WT_unit_status = wesnoth.theme_items.unit_status

-- Not a public function. Don't call this yourself.
function wesnoth.theme_items.unit_status()
	local u = wesnoth.get_displayed_unit()
	if not u then return {} end

	-- Get the engine's report so we can add to it.
	local status_display = _WT_unit_status()

	-- Add our elements for reporting custom statuses.
	for i, entry in ipairs(theme_ui_unit_statuses) do
		if u[entry.source][entry.id] then
			table.insert(status_display, { "element", {
				image = entry.icon,
				tooltip = entry.tooltip,
			}})
		end
	end

	return status_display
end

--[[

Registers a unit status that can be displayed in the Theme UI.

Arguments table:

    id:         The status id (e.g. "poisoned").
    icon:       The image path for the status icon.
    tooltip:    The tooltip displayed when hovering the status icon.
    source:     (Optional) The source store, referring to the name of the unit
                WML container with the status flag. This is "status" by
                default, but it is possible (albeit discouraged) to use
				"variables" instead.

]]
function register_unit_status_display(params)
	if params.source == nil then
		params.source = "status"
	end

	table.insert(theme_ui_unit_statuses, {
		id       = params.id,
		icon     = params.icon,
		tooltip  = params.tooltip,
		source   = params.source,
	})

	wprintf(W_INFO, "registered Theme UI display for unit status %s.%s", params.source, params.id)
end

------------------------
-- NAIA UNIT STATUSES --
------------------------

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

register_unit_status_display {
	id      = "necrosed",
	icon    = "misc/necrosed-status-icon.png",
	tooltip =  _ "necrosed: This unit is undergoing necrosis.",
}
