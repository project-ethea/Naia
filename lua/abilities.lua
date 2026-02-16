--
-- Abilities and weapon specials support library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2021 - 2026 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

local ALL_DAMAGE_TYPES = { "blade", "pierce", "impact", "fire", "cold", "arcane" }

-----------------------
-- ABILITY - STEALTH --
-----------------------

local STEALTH_TERRAINS = {
	{
		label  = _ "Forest",
		icon   = "terrain/grass/green4.png~BLIT(terrain/forest/mixed-summer-tile.png)",
		filter = "*^F*,*^Qhhf,*^Qhuf"
	},
	{
		label  = _ "Sand",
		icon   = "terrain/sand/desert5.png~BLIT(terrain/embellishments/plants/desert-plant9.png)",
		filter = "D*, D*^*, *^D*"
	},
	{
		label  = _ "Cave",
		icon   = "terrain/cave/floor4.png",
		filter = "U*, U*^*, *^U*, T*, T*^*, *^T*"
	}
}

-- FIXME: experimental!
local STEALTH_USE_CUSTOM_MENU = true

function wesnoth.wml_actions.stealth_ability_ui(cfg)
	local units = wesnoth.units.find_on_map(cfg)
	if not units then
		wprintf(W_DBG, "[stealth_ability_ui] No units to modify found")
		return
	end

	local menu = {}
	for i = 1, #STEALTH_TERRAINS do
		local icon = STEALTH_TERRAINS[i].icon
		if not STEALTH_USE_CUSTOM_MENU then
			icon = icon .. "~SCALE(30,30)"
		end
		table.insert(menu, {
			icon = icon,
			label = STEALTH_TERRAINS[i].label
		})
	end

	local result = 0

	if STEALTH_USE_CUSTOM_MENU then
		result = synced_horizontal_choice(menu, _ "Select Stealth Terrain", nil, true)
	else
		result = wesnoth.sync.evaluate_single(function()
			return { value = gui.show_menu(menu) }
		end).value
	end

	if result > 0 then
		for i, unit in ipairs(units) do
			unit.variables.stealth_terrain = STEALTH_TERRAINS[result].filter
		end
	end
end

--
-- SUF helper for the stealth ability.
--
-- NOTE #1:
--
-- It does not seem possible at the moment to reliable determine the location
-- that is being selected with the mouse to evaluate unit movements, e.g. by
-- selecting the unit then hovering a different tile. Namely, what we get from
-- wesnoth.interface.get_hovered_hex can be nil if the mouse is out of bounds,
-- and the SUF lua_function can get called even when a different/no unit is
-- selected. Our only option at the moment is to work with the unit's real
-- position, which makes the ambush icon overlay shown when hovering on other
-- tiles work only when the unit is already hidden at its present location.
--
-- NOTE #2:
--
-- This exists because I couldn't quite figure out how to use a formula in a
-- SLF nested in a SUF to achieve the same:
--
--   terrain="$(if(length('$this_unit.variables.stealth_terrain') > 0, '$this_unit.variables.stealth_terrain', '{ABILITY_STEALTH:FOREST_TERRAINS}'))"
--
-- The code above *works*... as long as the unit doesn't move, where for some
-- reason $this_unit becomes a null variable, which results in console log
-- spam and the formula falling back to the forest terrain filters when the
-- unit is in the middle of moving between two locations. Since the console
-- spam is annoying AND the constant switch between filters may cause
-- unforeseen issues, I opted to do things by hand in Lua instead.
--
function naia_stealth_unit_filter(u)
	if not u then
		wprintf(W_ERR, "naia_stealth_unit_filter(): bad unit")
		return
	end

	local terrains = u.variables.stealth_terrain or
		STEALTH_TERRAINS[1].filter or
		wml.error("naia_stealth_unit_filter(): catastrophic failure pls report ~_~")

	return wesnoth.map.matches(u.x, u.y, { terrain = terrains })
end

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
		wesnoth.current.map[{e.x1, e.y1}] = wesnoth.map.replace_overlay("^Fetd")
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
