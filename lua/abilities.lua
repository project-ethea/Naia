--
-- Abilities and weapon specials support library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2021 - 2023 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local T = wml.tag

local ALL_DAMAGE_TYPES = { "blade", "pierce", "impact", "fire", "cold", "arcane" }

-------------------------
-- ABILITY - TESTAMENT --
-------------------------

--
-- We only want ground terrains. Snow is a special case because it shares its prefix character
-- with a non-ground terrain, Ice (Ai). We also allow terrains with embellishments, rubble, oasis,
-- rails or light on them to match, but any other overlays are off-limits here.
--
-- Insert Konrad2 here going 'b-but the rules are unclear!'.
--

local UA_TESTAMENT_BASES    = { 'Aa', 'D*', 'G*', 'I*', 'R*', 'T*', 'Y*' }
local UA_TESTAMENT_OVERLAYS = { '^Do', '^Dr', '^B*', '^E*', '^I*' }
local UA_TESTAMENT_TERRAINS = {}

for i, v in ipairs(UA_TESTAMENT_BASES) do
	table.insert(UA_TESTAMENT_TERRAINS, v)
	for j, w in ipairs(UA_TESTAMENT_OVERLAYS) do
		table.insert(UA_TESTAMENT_TERRAINS, v .. w)
	end
end

function wesnoth.wml_actions.ua_testament_terraform()
	-- PRECONDITIONS:
	--  * the ability-possessing unit is at x1, y1

	-- TODO: query using Lua API in Wesnoth 1.15.x without storing garbage in WML
	local function location_has_items(x, y)
		wesnoth.wml_actions.store_items {
			x = x,
			y = y,
			variable = "temp_UA_TESTAMENT_item_test"
		}

		if wml.variables.temp_UA_TESTAMENT_item_test then
			wml.variables.temp_UA_TESTAMENT_item_test = nil
			return true
		end

		return false
	end

	local e = wesnoth.current.event_context

	if wesnoth.match_location(e.x1, e.y1, { terrain = UA_TESTAMENT_TERRAINS }) and not location_has_items(e.x1, e.y1) then
		wesnoth.audio.play("wose-attack.ogg")
		wesnoth.interface.delay(250)
		wesnoth.set_terrain(e.x1, e.y1, "^Fetd", "overlay")
		wesnoth.wml_actions.redraw {}
	end
end

---------------------------
-- WEAPON SPECIAL - MARK --
---------------------------

local SP_MARK_RES_BONUS =  20
local SP_MARK_RES_MAX   = 150

function wesnoth.wml_actions.sp_mark_calculate_bonus(cfg)
	-- PRECONDITIONS:
	--  * the attack target is at x2, y2

	local target_var = cfg.variable or "resistances"

	local e = wesnoth.current.event_context
	local target = wesnoth.units.get(e.x2, e.y2)

	local resistances = {}

	for i, dmg_type in ipairs(ALL_DAMAGE_TYPES) do
		local base_res = target:resistance(dmg_type)
		local new_res = math.min(SP_MARK_RES_MAX, target:resistance(dmg_type) + SP_MARK_RES_BONUS)
		if base_res ~= new_res then
			-- We store an adjustment value, not new_res. This is to avoid excessive
			-- weirdness if some other resistance-altering object gets removed in the
			-- meantime. Obviously our adjustment may still become obsolete around the
			-- maximum cap, but what can you do.
			wml.variables[target_var .. "." .. dmg_type] = new_res - base_res
		end
	end
end
