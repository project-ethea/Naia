--
-- GUI2 widget definitions used by Naia GUI elements
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2020 - 2025 by Iris Morelle <iris@irydacea.me>
--
-- See COPYING for usage terms.
--

local T = wml.tag

-- #textdomain wesnoth-Naia
local _ = wesnoth.textdomain "wesnoth-Naia"

-- Constants and helpers

local JOURNEYLOG_BIO_PORTRAIT_SIZE = 200

local JOURNEYLOG_PANEL_PADDING = 3
local JOURNEYLOG_PANEL_BORDER_COLOR = "114, 79, 46, 127" -- GUI__BORDER_COLOR_DARK

--
-- Helper to avoid code duplication and odd semantics in GUI2 calls.
--
local function G_widget(widget_class, id, cfg)
	cfg.id = id
	cfg.description = "a decade and a half later, gui2 still sucks"
	gui.add_widget_definition(widget_class, id, {
		-- id and description are duplicated in order to prevent a WML error:
		-- "In section '[styled_widget]' the mandatory key 'id/description' isn't set."
		id          = id,
		description = "a decade and a half later, gui2 still sucks",
		T.resolution(cfg)
	})
end

--
-- Helper to build a round border around the canvas edges.
--
local function C_round_frame(params)
	local color = params.color or "0, 0, 0, 255"
	local thickness = params.thickness or 1
	return T.line {
		x1 = 1,
		y1 = 0,
		x2 = "(width - 2)",
		y2 = 0,
		thickness = thickness,
		color = color
	},
	T.line {
		x1 = 0,
		y1 = 1,
		x2 = 0,
		y2 = "(height - 2)",
		thickness = thickness,
		color = color
	},
	T.line {
		x1 = 1,
		y1 = "(height - 1)",
		x2 = "(width - 2)",
		y2 = "(height - 1)",
		thickness = thickness,
		color = color
	},
	T.line {
		x1 = "(width - 1)",
		y1 = 1,
		x2 = "(width - 1)",
		y2 = "(height - 2)",
		thickness = thickness,
		color = color
	}
end

-- Canvas definition WML

G_widget("window", "naia_campaign_intro", {
	-- Mystery magic numbers from _GUI_RESOLUTION_BORDERLESS_BASE, found
	-- in data/gui/widget/window_borderless.cfg on Wesnoth 1.18.
	left_border = 10,
	right_border = 13,
	top_border = 10,
	bottom_border = 13,

	-- We paint the whole screen black to hide the loading screen behind
	-- our dialog.
	T.background {
		T.draw {
			T.rectangle {
				x = 0,
				y = 0,
				w = "(width)",
				h = "(height)",
				fill_color = "0, 0, 0, 255"
			}
		}
	},
	T.foreground {
		T.draw {}
	},
	T.grid {
		T.row {
			grow_factor = 1,
			T.column {
				horizontal_alignment = "center",
				vertical_alignment = "center",
				T.scrollbar_panel {
					vertical_scrollbar_mode = "initial_auto",
					horizontal_scrollbar_mode = "initial_auto",
					T.definition {
						T.row {
							T.column {
								horizontal_grow = true,
								vertical_grow = true,
								T.grid {
									id = "_window_content_grid"
								}
							}
						}
					}
				}
			}
		},
		T.row {
			T.column {
				T.button {
					id = "click_dismiss",
					definition = "default",
					label = wgettext("Close", "wesnoth-lib")
				}
			}
		}
	}
})

G_widget("window", "naia_journeylog", {
	-- Mystery magic numbers from _GUI_RESOLUTION_BORDERLESS_BASE, found
	-- in data/gui/widget/window_borderless.cfg on Wesnoth 1.18.
	left_border = 10,
	right_border = 13,
	top_border = 10,
	bottom_border = 13,

	T.background {
		T.draw {
			T.pre_commit {
				T.blur {
					depth = 8
				}
			},
			T.image {
				x = 0,
				y = 0,
				w = "(width)",
				h = "(height)",
				-- Brighten it up a bit
				name = "dialogs/translucent65-background.png~CS(20,22,26)",
				resize_mode = "tile_highres"
			},
			T.image {
				x = 0,
				y = 0,
				w = "(width)",
				h = "(height * 0.66)",
				name = "misc/journeylog-bg.png",
				resize_mode = "stretch"
			}
		}
	},
	T.foreground {
		T.draw {}
	},
	T.grid {
		T.row {
			grow_factor = 1,
			T.column {
				horizontal_grow = false, -- !!!
				vertical_grow = true,
				T.scrollbar_panel {
					vertical_scrollbar_mode = "initial_auto",
					horizontal_scrollbar_mode = "initial_auto",
					T.definition {
						T.row {
							T.column {
								horizontal_grow = true,
								vertical_grow = true,
								T.grid {
									id = "_window_content_grid"
								}
							}
						}
					}
				}
			}
		},
		T.row {
			T.column {
				T.button {
					id = "click_dismiss",
					definition = "default",
					label = wgettext("Close", "wesnoth-lib")
				}
			}
		}
	}
})

G_widget("panel", "naia_journeylog_panel", {
	left_border   = JOURNEYLOG_PANEL_PADDING,
	right_border  = JOURNEYLOG_PANEL_PADDING,
	top_border    = JOURNEYLOG_PANEL_PADDING,
	bottom_border = JOURNEYLOG_PANEL_PADDING,

	T.background {
		T.draw {
			T.rectangle {
				x = 1,
				y = 1,
				w = "(width - 2)",
				h = "(height - 2)",
				border_thickness = 1,
				border_color = "0, 0, 0, 255",
				fill_color = "0, 0, 0, 127" -- GUI__BACKGROUND_COLOR_ENABLED
			},
			C_round_frame({ color = JOURNEYLOG_PANEL_BORDER_COLOR })
		}
	},
	T.foreground {
		T.draw {}
	}
})

local function journeylog_bio_portrait_canvas_image(image_func)
	return T.image {
		name = "('[text][ipf]' where ipf = '" .. (image_func or "") .. "')",
		--name = "(text)",
		x = "(if(image_original_width < width, (width - image_original_width)/2, 0))",
		y = "(if(image_original_width < height, (height - image_original_height)/2, 0))",
		-- BIG TODO: scale images proportionally if they don't fit
		w = "(min(image_original_width, width) * image_original_width/image_original_height)",
		h = "(min(image_original_height, height))",
		resize_mode = "scale"
	}
end

local function journeylog_bio_portrait_canvas(params)
	local border = params.border or "114, 79, 46, 127"
	local bg = params.bg or "0, 0, 0, 127"
	local image_func = params.image_func or ""

	return T.draw {
		T.rectangle {
			w = "(width)",
			h = "(height)",
			fill_color = bg
		},
		journeylog_bio_portrait_canvas_image(image_func),
		T.rectangle {
			x = 1,
			y = 1,
			w = "(width - 2)",
			h = "(height - 2)",
			border_thickness = 1,
			border_color = "0, 0, 0, 255",
		},
		C_round_frame({ color = border })
	}
end

G_widget("button", "naia_journeylog_image_viewer_button", {
	min_width         = JOURNEYLOG_BIO_PORTRAIT_SIZE,
	min_height        = JOURNEYLOG_BIO_PORTRAIT_SIZE,
	default_width     = JOURNEYLOG_BIO_PORTRAIT_SIZE,
	default_height    = JOURNEYLOG_BIO_PORTRAIT_SIZE,
	max_width         = 0,
	max_height        = JOURNEYLOG_BIO_PORTRAIT_SIZE,

	text_extra_width  = 0,
	text_extra_height = 0,
	text_font_size    = 0,

	T.state_enabled {
		journeylog_bio_portrait_canvas({})
	},
	T.state_disabled {
		journeylog_bio_portrait_canvas({
			border = "79, 79, 79, 95",
			image_func =  "~GS()~O(0.6)"
		})
	},
	T.state_pressed {
		journeylog_bio_portrait_canvas({
			image_func = "~BLEND(0,0,0,0.08)"
		})
	},
	T.state_focused {
		journeylog_bio_portrait_canvas({
			bg = "18, 24, 40, 127",
			image_func = "~BLEND(255,255,255,0.02)"
		})
	}
})
