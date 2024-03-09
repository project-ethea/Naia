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

local function screen_color_adjust(r, g, b)
	wesnoth.interface.color_adjust(r, g, b)
end

local function screen_color_fade_step(r, g, b, step_delay)
	screen_color_adjust(r, g, b)
	wesnoth.interface.delay(step_delay)
	wesnoth.wml_actions.redraw {}
end

local function color_compare(a, b)
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

local function color_add(c, a)
	c[1] = c[1] + a
	c[2] = c[2] + a
	c[3] = c[3] + a
end

-- step_direction: 1 for +infinity, -1 for -infinity
local function screen_color_fade_internal(color1, color2, step_direction, step_size, step_delay)
	local c = color1

	screen_color_fade_step(c[1], c[2], c[3], step_delay)

	repeat
		color_add(c, step_direction * step_size)
		screen_color_fade_step(c[1], c[2], c[3], step_delay)
	until color_compare(c, color2) == true
end

function wesnoth.wml_actions.fade_to_black(cfg)
	-- assume start at 0,0,0
	screen_color_fade_internal({-32,-32,-32}, {-256,-256,-256}, -1, 32, 5)
	screen_color_fade_step(-512, -512, -512, 5)
end

function wesnoth.wml_actions.fade_in(cfg)
	-- assume start at -512,-512,-512
	screen_color_fade_internal({-256,-256,-256}, {0,0,0}, 1, 32, 5)
end
