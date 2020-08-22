Naia - Project Ethea Phase 1 Shared Library - Changelog
=======================================================

Version 20200816+dev:
---------------------
* Lua and WML library:
  * Add `[variable_is_even]` WML conditional tag along with `VARIABLE_IS_EVEN`
    and `VARIABLE_IS_ODD` macros.
  * Add `VARIABLE_COPY` and `VARIABLE_ARRAY_COPY` macros.
  * Fix issues with `[harm_multiple_units]` crashing when there isn't a valid
    attack source.
  * Made `AMLA_BUG_4419_WORKAROUND` a no-op on 1.15.4 and later since mainline
    #4419 is solved there.

* Terrains:
  * Implemented a new Dark Hive transition logic to avoid issues with the
    deprecated Mushroom Grove `^Uf*` terrain as well as the new Mycelium `T*`
    base terrain proper when running add-ons on Wesnoth 1.15.2 and later
    (issue #11, see also IftU #73 and AtS #83).


Version 20200816:
-----------------
* Lua and WML library:
  * Fixed persistent WML variables API crashing when trying to manipulate the
    global table on a fresh persistent store or a store without a preexisting
    global table.


Version 20200814:
-----------------
* Lua and WML library:
  * Made compatibility layer defer UI actions until the preload event in order
    to avoid giving Wesnoth an existential crisis (issue #15).
  * Fixed grave issues with the compatibility check code resulting in Naia
    callers not completing root `[lua]` initialization under specific
    circumstances (<https://r.wesnoth.org/p657381>).


Version 20200812:
-----------------
* Lua and WML library:
  * Added basic facilities for log indentation.
  * Added `[harm_multiple_units]` WML action tag to implement animated AoE
    weapon specials.


Version 20200810:
-----------------
* Language and i18n:
  * Updated translations: Russian.

* Lua and WML library:
  * Added persistent WML variables API based on the AtS 0.10.x version.


Version 20200808:
-----------------
* Graphics:
  * Added Wight by Santiago Iborra (for WTactics.org/Arcmage.org) as a
    replacement placeholder for Mal Hekuba's portrait.

* Language and i18n:
  * Updated translations: Russian.

* Lua and WML library:
  * Added `table_dump` function to return a user-readable string representation
    of a table for debugging purposes.
  * Added `opposite=` option to `[store_direction]`.
  * Added `[unit_location_is_passable]` WML conditional tag.
  * Added `OVERWRITE` and `PASSABLE` utility macros for `[unit]` placement
    options.
  * Added `register_unit_status_display()` function to implement a cleaner API
    for adding new unit status display items (dehydration, stunned, etc.).
  * Moved all IftU and AtS AI macros, presets, and engines into Naia.

* Terrains:
  * Fixed Dark Hive terrain transitions drawing through stone walls.
  * Fixed Dark Hive Cells being drawn over certain transitions (especially
    stone walls and castle/keep walls).

* Units:
  * Fixed obscures ability not really doing anything (PR #2).
  * Increased base Shaxthal resistances to arcane damage from -10% to 0%.
  * Increased Chaos Magus resistance to arcane damage from 0% to 10%.
  * Increased Chaos Lorekeeper resistance to arcane damage from -20% to -10%.
  * Gave Shaxthal Worm the burrow ability (hides in walls, deals 50% more
    damage on defense)
  * Increased Shaxthal Drone's HP from 28 to 32.
  * Increased Shaxthal Sentry Drone's HP from 46 to 51.
  * Increased Shaxthal Enforcer Drone's HP from 62 to 65.
  * Increased Shaxthal Assault Drone's HP from 42 to 47.
  * Increased Shaxthal War Drone's HP from 56 to 62.
  * Increased Shaxthal Runner Drone's HP from 29 to 31.
  * Increased Shaxthal Protector Drone's HP from 38 to 45.
  * Increased Shaxthal Rayblade's HP from 36 to 39.
  * Increased Shaxthal Stormblade's HP from 49 to 54.
  * Increased Shaxthal Razorbird's HP from 26 to 28.
  * Increased Shaxthal Thunderbird's HP from 39 to 41.
  * Increased Shaxthal Protector Drone's MP from 5 to 6 to match its L1.
  * Increased Demon's HP from 31 to 32.
  * Increased Demon Grunt's HP from 40 to 43.
  * Increased Demon Warrior's HP from 56 to 59.
  * Increased Demon Zephyr's HP from 38 to 39.
  * Increased Faerie Sprite's HP from 22 to 25.
  * Increased Faerie Sprite's XP from 40 to 50.
  * Decreased Faerie Sprite's cost from 21 to 20.
  * Increased Faerie Sprite's melee damage from 2-3 to 3-3.
  * Increased Fire Faerie's HP from 32 to 38.
  * Increased Fire Faerie's XP from 70 to 90.
  * Increased Fire Faerie's melee damage from 3-4 to 4-4.
  * Increased Faerie Dryad's HP from 46 to 50.
  * Increased Faerie Dryad's melee damage from 4-5 to 5-5.
  * Increased Faerie Spirit's HP from 40 to 45.
  * Increased Faerie Spirit's melee damage from 5-5 to 6-5.
  * Increased Faerie Spirit's ranged damage from 5-5 to 6-5.
  * Gave Chaos Cardinal the zeal ability (+30% to all resistances, max. 60% for
    non-arcane, max. 30% for arcane, level diff * 15% damage bonus).
  * Gave Chaos Cardinal the necrosis weapon special (living targets receive 10
    damage per turn until cured, necrosed units turn into Ghouls belonging to
    the infecter's side upon death).


Version 20200724.1:
-------------------
* Language and i18n:
  * Updated translations: Russian (complete).


Version 20200724:
-----------------
* Graphics:
  * New or updated unit graphics: Giant Ant.

* Language and i18n:
  * Updated translations: Russian (complete).

* Lua and WML library:
  * Added `[variable_default]` and `VARIABLE_DEFAULT` macro.
  * Fixed collectable items prompt triggering during replays and causing OOS
    issues, as well as not behaving properly on keyboard Enter/Esc presses.
  * Removed `hex_facing` function and its implementation details, superseded by
    mainline APIs in version 20200620.
  * Added `opposite=` option to `[set_facing]`, along with an `OPPOSITE_FACING`
    macro for the `FACE_*` utility macros.

* Terrains:
  * Added snow and rain weather effects.
  * Added snowy and dead oak Great Tree variants from Archaic Resources.
  * Fixed some technical terrains being available in the Help browser.

* Units:
  * Added a hint for partially-locked advancement trees (AtS E1 and E2) to the
    Unit Advancements dialog.
  * Added an option to toggle back to the on-map unit stats to the Unit
    Advancements dialog.
  * Units of the spirits race now get the mainline elemental trait instead of
    the custom spirit trait. Note that this makes them not receive the
    `not_living` status anymore.


Version 20200628:
-----------------
* Language and i18n:
  * Updated translations: Russian (complete).

* Terrains:
  * Added snow and rain weather effects.
  * Added snowy and dead oak Great Tree variants from Archaic Resources.


Version 20200625:
-----------------
* Lua and WML library:
  * Add `table_size`, `table_empty`, `table_keys`, `table_merge` global functions.
  * Moved `AMLA_VITALITY` macro from AtS.
  * Fixed OOS errors in replays due to cutscene skipping with `[move_unit_fake]`
    causing the unit counter to desync (After the Storm #68).

* Language and i18n:
  * Updated translations: Spanish (complete).

* Units:
  * Added a context menu option to browse through custom AMLAs for player units
    that have them (e.g. the protagonists of IftU and AtS) (issue #3, After the
    Storm #69, Invasion from the Unknown #70).
  * Revised race descriptions: Shaxthals.
  * Revised unit descriptions: Water Tidal, Water Spirit, Aragwaith Sorceress,
    Aragwaith Guard, Aragwaith Greatbow, Aragwaith Swordsmaster.


Version 20200621:
-----------------
* General:
  * Updated art licenses for CC BY-NC-ND 4.0, CC BY-SA 4.0 and CC0 content.

* Terrains:
  * Fixed Wall Moss terrain not having working graphics when playing IftU
    instead of AtS.


Version 20200620:
-----------------
* Lua and WML library:
  * Added [fade_to_black] and [fade_in] to the list of skippable actions to
    solve issues with terrains remaining in dark screen mode when skipping
    certain cutscenes using them, e.g. AtS E3S1.
  * Patch a border case with FORCE_CHANCE_TO_HIT in Wesnoth 1.14 affecting
    scenarios such as AtS E3S3.
  * Added a mechanism to inject global events without relying on [campaign].
  * Major characters with AMLA upgrades available now have their XP bar
    displayed in blue.
  * Added [item_prompt] and adapted IftU's PICK_UP macro to make use of it.
  * Added UNIT_SPEAKS_FOR_UNDEAD_MINION* from IftU.
  * Fixed [invert_direction] yielding north for north.
  * Added [no_op].
  * Added [variable_in] and [position_equals] WML conditional tags.
  * Added VARIABLE_IF_ELSE, VARIABLE_POS_EQUALS, VARIABLE_LEXICAL_IN utility
    macros.

* Units:
  * Chaos Cardinal migrated from IftU and expanded with a new baseframe by
    VYNLT and slightly different stats over the mainline Ancient Lich:
    * 80 HP -> 89 HP
    * Melee 8-4 -> 9-3, plague(Ghoul) weapon special added
  * Door unit event handlers now have unique ids.
  * Chaos Hound unit line now belongs to the wolf race, giving them traits and
    names accordingly.
  * Removed overlong death animation for the Aragwaith Lancer that only uses
    the baseframe as a placeholder.
  * Terror ability no longer affects same-level units.

* Terrains:
  * Migrated Flat and Rough Overlay terrains from AtS.


Version 20180722:
-----------------
* Lua and WML library:
  * [fade_to_black] and [fade_in] now use wesnoth.color_adjust() directly
    instead of the [color_adjust] action.
  * Implemented code to make certain WML actions be skipped or take effect
    instantly when pressing Escape on [message] dialogs. This makes it possible
    to skip cutscenes much faster:
      * [move_unit_fake]
      * [move_units_fake]
      * [animate_unit]
      * [sound]
      * [delay]
      * [color_adjust]
      * [floating_text]
      * [scroll_to]
      * [scroll_to_unit]
      * [fade_out_music]
      * [fade_out_sound_effects]
      * [fade_in_sound_effects]
  * Removed BREAK, FOR, REVERSE_FOREACH, REVERSE_NEXT macros in favour of
    using [for], [foreach], [continue], and [break] in 1.14 instead.

* Units:
  * Aragwaithi humans now use the same race icons as regular humans.
  * Fixed Protection ability capping resistances to 50% for units which already
    have base resistances greater than 50% on their own (patch by newfrenchy83).


Version 20180611:
-----------------
* General:
  * Initial version with Wesnoth 1.14 support.
  * Dropped compatibility with Wesnoth versions prior to 1.13.11.

* Language and i18n:
  * Updated French translation from newfrenchy83 (core set extracted from
    AtS).
  * Merged translations of the core set from IftU and AtS: Spanish, French,
    Hungarian, Italian, Japanese, Russian, Turkish.

* Lua and WML library:
  * Replaced the AtS implementation of [setup_doors] with its IftU counterpart,
    with minor code improvements and the addition of the AtS requirement for
    target locations to be vacant. Otherwise, the semantics of the AtS
    implementation break IftU S22A and possibly others that require a custom
    SLF.
  * [setup_doors] and the Door unit support the new Gate terrains from 1.14.
  * [unstore_unit] male/female_text is used where needed instead of the clunky
    checks and variable assignments used before.
  * Patch [change_theme] crash on 1.14.1 and earlier when theme= is not
    specified.
  * Standard macros no longer use FOREACH.

* Terrains:
  * Event gates are now implemented as recolored mainline Rusy Gates. The open
    variations are currently unused since event gates are normally handled as
    barriers that get instantly removed.
  * Included wall moss terrain from AtS for use in IftU 2.1.0.

* Units:
  * Added faerie race icon by LordBob.
  * Set unit bars offset for the Matrix Flow System.
  * Use the new 1.14 staff sounds for staff-wielding units.
  * Set the Chaos Hound line's undead variation to wolf (IftU issue #34).
  * Simplified implementation of Terror and Protection abilities.

* User interface library:
  * Scenario title cards use a larger font size to compensate for the increased
    UI font sizes in 1.14.
  * Improved experimental version and bugcheck dialogs, including a link to the
    campaign's forum thread or tracker URL as applicable.
  * Bugcheck dialogs use monospace text for the details section.


; kate: indent-mode normal; encoding utf-8; space-indent on; word-wrap on;
; kate: indent-width 2;
