--
-- Lua versions of mainline WML macros to reduce the campaign's WML footprint
-- (memory and disk usage).
--
-- See macros/optimizations.cfg.
--

function wesnoth.wml_actions.quake(cfg)
	local sound = cfg.sound

	if sound then
		wesnoth.audio.play(sound)
	end

	local shake_dist = math.max(1, cfg.strength or 10)
	local length = math.max(1, cfg.length or 4)

	for _ = 1, length do
		wesnoth.interface.scroll(     shake_dist,               0)
		wesnoth.interface.scroll(-2 * shake_dist,               0)
		wesnoth.interface.scroll(     shake_dist,      shake_dist)
		wesnoth.interface.scroll(              0, -2 * shake_dist)
		wesnoth.interface.scroll(              0,      shake_dist)
	end
end

function wesnoth.wml_actions.fade_to_black(cfg)
	local duration = cfg.duration or 1000
	wesnoth.interface.screen_fade({0, 0, 0, 255}, duration)
end

function wesnoth.wml_actions.fade_in(cfg)
	local duration = cfg.duration or 1000
	wesnoth.interface.screen_fade({0, 0, 0, 0}, duration)
end
