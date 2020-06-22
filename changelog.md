Naia - Project Ethea Phase 1 Shared Library - Changelog
=======================================================

Version 20200621+dev:
---------------------
* Units:
  * Revised unit descriptions: Water Tidal, Water Spirit, Aragwaith Sorceress.


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