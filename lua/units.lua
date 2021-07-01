--
-- Unit and unit types utilitys library
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2021 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local _ = wesnoth.textdomain "wesnoth-Naia"

---------------------------------------------
-- VERLISSH NAME GENERATORS IMPLEMENTATION --
---------------------------------------------

-- po: Generator for Verlissh machine part names; see <https://wiki.wesnoth.org/Context-free_grammar> for the
-- po: syntax documentation.
-- po: .
-- po: Try to keep `structure_type` and `node_type` as short as possible, using abbreviations (WITHOUT dots)
-- po: if necessary. Bonus points if you use technical or obscure words for this.
-- po: .
-- po: The original English version uses the following abbreviated forms:
-- po: .
-- po:  * Tr    = Trunk
-- po:  * Br    = Branch
-- po:  * Jnc   = Junction
-- po:  * Co    = Core
-- po:  * Le    = Leaf
-- po:  * Rt    = Root
-- po:  * Aux   = Auxiliary
-- po:  * Lo    = Lower
-- po:  * Up    = Upper
-- po:  * Prt   = Port
-- po:  * Ln    = Line
-- po:  * Par   = Parallel
-- po: .
-- po: Because of issues with randomization (?), `number` and `upalpha` actually produce placeholders filled in
-- po: through a later step using Lua instead. Anywhere in the generated name where a `@` is found, an uppercase
-- po: Latin letter (English only) is substituted, while `%` is substituted with a Roman numeral (0-9).

local unused = _ "TRANSLATORS: the comment attached to this msgid applies to the next two entries"

local VERLISSH_PART_NAMES = _ [[main={structure_type} {id}

structure_type=Br|Jnc|Aux|Lo|Up|Ln|Par

id={series}{unitno}|{series}{unitno_suffixed}
series={upalpha}|{upalpha}{upalpha}
unitno={number}{number}{number}{number}-{number}{number}
unitno_suffixed={number}{number}{number}{number}-{number}{suffix}
suffix=A|B|C|D|E|F

number=%
upalpha=@
]]

local VERLISSH_CORE_NAMES = _ [[main={node_type} {id}

node_type=Co|Hub|Jnc|Aux|Rt|Tr|Le|Prt

id={series}{unitno}|{series}{unitno}{suffix}
series={upalpha}|{upalpha}{upalpha}
unitno={number}-{number}{number}
suffix=A|B|C|D|E|F|α|β|γ

number=%
upalpha=@
]]

local function do_verlissh_namegen(namegen_cfg)
	-- Give us a name with placeholder characters.
	local name = str2table(wesnoth.name_generator('cfg', tostring(namegen_cfg))())

	-- Fill in placeholders in the name generator's output.
	for i, char in ipairs(name) do
		-- NOTE: We use an unsynced RNG here in order to avoid altering the
		--       synced RNG state an excessive number of times per unit
		--       placement. Our caller is responsible for synchronizing the
		--       final result.
		if char == '@' then
			name[i] = random_char_unsynced("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
		elseif char == '%' then
			name[i] = random_char_unsynced("0123456789")
		end
	end

	-- Deliver the output ready for use with synchronize_choice.
	return { name = table.concat(name) }
end

function wesnoth.wml_actions.verlissh_namegen()
	local ev = wesnoth.current.event_context
	local u = wesnoth.get_unit(ev.x1, ev.y1)

	if u and (not u.name or tostring(u.name) == "") then
		local namegen_cfg = ''
		if u.type == "Verlissh Matrix Core" then
			namegen_cfg = VERLISSH_CORE_NAMES
		else
			namegen_cfg = VERLISSH_PART_NAMES
		end
		u.name = wesnoth.synchronize_choice(function()
			return do_verlissh_namegen(namegen_cfg)
		end).name
	end
end

-------------------------
-- CUSTOM UNIT EFFECTS --
-------------------------

function wesnoth.effects.level(u, cfg)
	local level_new = cfg.new_level or helper.wml_error("[effect] apply_to=level requires new_level= value")
	u.level = level_new
end
