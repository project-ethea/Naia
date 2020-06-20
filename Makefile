# Run validation tests

ADDON_NAME           := Naia

DIST_VERSION_FILE    := dist/VERSION

include ../Naia/tools/Makefile.wmltools

normalize-textdomains:
	find . \( -name '*.cfg' -o -name '*.lua' \) -type f -print0 | xargs -0 \
		sed -ri 's/wesnoth-(Invasion_from_the_Unknown|After_the_Storm|Era_of_Chaos)/wesnoth-Naia/'

clean: clean-wmltools
