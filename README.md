codename Naia
================================================================================

**Naia** is a framework/code and resources library for the **[Battle for Wesnoth][1]**
add-ons developed under the **[Project Ethea][2]** organization. As of this writing,
this includes the **[Invasion from the Unknown][3]** and **[After the Storm][4]**
campaigns.

[1]: <https://www.wesnoth.org/>
[2]: <https://github.com/project-ethea/>
[3]: <https://github.com/project-ethea/Invasion_from_the_Unknown>
[4]: <https://github.com/project-ethea/After_the_Storm>

This is **not** a Wesnoth add-on and it will not do anything on its own if
installed. It is, however, a hard dependency for IftU and AtS. When installing
the campaigns from the Git repositories (as opposed to using the versions from
the official add-ons server) you have the choice of installing Naia inside each
campaign’s directory (not recommended, but this is used for official
distribution), or installing it beside the campaigns in the Wesnoth add-ons
directory. The latter method is especially useful if you plan on keeping both
campaigns around.

Do note that due to the shared nature of Naia, changes in it may break either
campaign and this may not always be addressed immediately. In particular, it is
not advisable to use a version of Naia other than the one shipped when playing
release versions of the campaigns.

Naia presently requires **Wesnoth 1.14**. Versions 1.14.2 and later are
recommended, and it may also work with versions 1.13.12 through 1.13.14, albeit
you will not receive any support for attempting to use those versions.


Reporting issues
--------------------------------------------------------------------------------

If you encounter any issues with a campaign that depends on Naia, you must
report them on the campaign’s development topic on the Wesnoth.org forums.
Alternatively, if you are 100% positive that the issue lies within Naia, you
may consider using its own bug [tracker][5] instead.

[5]: <https://github.com/project-ethea/Naia/issues>

Be aware that depending on the nature of the problem, you may be asked to
provide a saved game file to reproduce it.


Contacting the author
--------------------------------------------------------------------------------

You may contact the author of this campaign via forum PM to Iris on the
[Wesnoth.org forums][6].

[6]: <https://forums.wesnoth.org/>
