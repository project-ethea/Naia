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
local JOURNEYLOG_BIO_SMALL_PORTRAIT_SIZE = 128

local JOURNEYLOG_PANEL_PADDING = 3
local JOURNEYLOG_PANEL_BORDER_COLOR = "114, 79, 46, 127" -- GUI__BORDER_COLOR_DARK

local JOURNEYLOG_SCROLLBAR_THICKNESS = 7
local JOURNEYLOG_SCROLLBAR_POSITIONER_LENGTH = 11
local JOURNEYLOG_SCROLLBAR_GROOVE_COLOR = "0, 0, 0, 47"
local JOURNEYLOG_SCROLLBAR_GROOVE_COLOR_HOVER = "0, 0, 0, 127"
local JOURNEYLOG_SCROLLBAR_SLIDER_COLOR = "23, 50, 73, 200"
local JOURNEYLOG_SCROLLBAR_SLIDER_COLOR_HOVER = "33, 66, 93, 200"

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

local function journeylog_bio_portrait_canvas_image(image_func, resize_mode)
	-- HACK:
	-- resize_mode is not a formula, so we cannot use a formula to define
	-- whether an image should be smoothly interpolated (portraits) or NN'd
	-- (sprites). HOWEVER, name IS a formula, so we render two variants of
	-- each image instead, with one being set to an empty pathname if it seems
	-- like the wrong variant for the image type in question.
	return T.image {
		name = string.format([[(
			if(resize_mode = 'scale' and is_portrait = 1,
				img_path,
				if(resize_mode = 'scale_sharp' and is_portrait = 0,
					img_path,
					''
				))
			where img_path = '[text]%s',
				  resize_mode = '%s',
				  is_portrait = (find_string(text, 'portraits/') = 0)
			)]], image_func, resize_mode),
		resize_mode = resize_mode,
		x = "(if(image_original_width < width, (width - image_original_width)/2, 0))",
		y = "(if(image_original_width < height, (height - image_original_height)/2, 0))",
		-- BIG TODO: scale images proportionally if they don't fit
		w = "(min(image_original_width, width) * image_original_width/image_original_height)",
		h = "(min(image_original_height, height))",
	}
end

local function journeylog_bio_portrait_canvas(params)
	local border = params.border or "114, 79, 46, 92"
	local bg = params.bg or "0, 0, 0, 127"
	local image_func = params.image_func or ""

	return T.draw {
		T.rectangle {
			w = "(width)",
			h = "(height)",
			fill_color = bg
		},
		journeylog_bio_portrait_canvas_image(image_func, 'scale'),
		journeylog_bio_portrait_canvas_image(image_func, 'scale_sharp'),
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

local function journeylog_bio_portrait_widget_def(widget_size)
	return {
		min_width         = widget_size,
		min_height        = widget_size,
		default_width     = widget_size,
		default_height    = widget_size,
		max_width         = 0,
		max_height        = widget_size,

		text_extra_width  = 0,
		text_extra_height = 0,
		text_font_size    = 0,

		T.state_enabled {
			journeylog_bio_portrait_canvas({})
		},
		T.state_disabled {
			journeylog_bio_portrait_canvas({
				border = "79, 79, 79, 92",
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
				border = "114, 79, 46, 110",
				bg = "18, 24, 40, 127",
				image_func = "~BLEND(255,255,255,0.02)"
			})
		}
	}
end

G_widget(
	"button",
	"naia_journeylog_image_viewer_button",
	journeylog_bio_portrait_widget_def(JOURNEYLOG_BIO_PORTRAIT_SIZE)
)

G_widget(
	"button",
	"naia_journeylog_image_viewer_button_small",
	journeylog_bio_portrait_widget_def(JOURNEYLOG_BIO_SMALL_PORTRAIT_SIZE)
)

local function journeylog_scroll_canvas(vertical, params)
	local groove_color = params.groove_color or JOURNEYLOG_SCROLLBAR_GROOVE_COLOR
	local slider_color = params.slider_color or JOURNEYLOG_SCROLLBAR_SLIDER_COLOR

	local x, y, w, h = 0, 0, "(width)", "(height)"
	local edge1 = { x1 = 0, y1 = 0, x2 = 0, y2 = 0, thickness = 1, color = slider_color }
	local edge2 = { x1 = 0, y1 = 0, x2 = 0, y2 = 0, thickness = 1, color = slider_color }

	if vertical then
		y = "(positioner_offset + 1)"
		h = "(max(0, positioner_length - 2))"

		edge1.x1 = 1
		edge1.x2 = "(width - 2)"
		edge1.y1 = "(positioner_offset)"
		edge1.y2 = edge1.y1

		edge2.x1 = edge1.x1
		edge2.x2 = edge1.x2
		edge2.y1 = "(positioner_offset + positioner_length - 1)"
		edge2.y2 = edge2.y1
	else
		x = "(positioner_offset + 1)"
		w = "(max(0, positioner_length - 2))"

		edge1.x1 = "(positioner_offset)"
		edge1.x2 = edge1.x1
		edge1.y1 = 1
		edge1.y2 = "(height - 2)"

		edge2.x1 = "(positioner_offset + positioner_length - 1)"
		edge2.x2 = edge2.x1
		edge2.y1 = edge1.y1
		edge2.y2 = edge1.y2
	end

	return T.draw {
		-- Groove
		T.rectangle {
			x = 0,
			y = 0,
			w = "(width)",
			h = "(height)",
			fill_color = groove_color
		},
		-- Positioner
		T.line(edge1),
		T.rectangle {
			x = x,
			y = y,
			w = w,
			h = h,
			fill_color = slider_color
		},
		T.line(edge2)
	}
end

local function journeylog_hscroll_canvas(params)
	return journeylog_scroll_canvas(false, params)
end

local function journeylog_vscroll_canvas(params)
	return journeylog_scroll_canvas(true, params)
end

G_widget("horizontal_scrollbar", "naia_journeylog_viewer_hscroll", {
	min_width         = 20,
	min_height        = JOURNEYLOG_SCROLLBAR_THICKNESS,
	default_width     = 20,
	default_height    = JOURNEYLOG_SCROLLBAR_THICKNESS,
	max_width         = 0,
	max_height        = JOURNEYLOG_SCROLLBAR_THICKNESS,
	left_offset       = 0,
	right_offset      = 0,
	minimum_positioner_length = JOURNEYLOG_SCROLLBAR_POSITIONER_LENGTH,

	T.state_enabled {
		journeylog_hscroll_canvas({})
	},
	T.state_disabled {
		T.draw {}
	},
	T.state_pressed {
		journeylog_hscroll_canvas({
			groove_color = JOURNEYLOG_SCROLLBAR_GROOVE_COLOR_HOVER,
			slider_color = JOURNEYLOG_SCROLLBAR_SLIDER_COLOR_HOVER
		})
	},
	T.state_focused {
		journeylog_hscroll_canvas({
			groove_color = JOURNEYLOG_SCROLLBAR_GROOVE_COLOR_HOVER,
			slider_color = JOURNEYLOG_SCROLLBAR_SLIDER_COLOR_HOVER
		})
	}
})

G_widget("vertical_scrollbar", "naia_journeylog_viewer_vscroll", {
	min_width         = JOURNEYLOG_SCROLLBAR_THICKNESS,
	min_height        = 20,
	default_width     = JOURNEYLOG_SCROLLBAR_THICKNESS,
	default_height    = 20,
	max_width         = JOURNEYLOG_SCROLLBAR_THICKNESS,
	max_height        = 0,
	top_offset        = 0,
	bottom_offset     = 0,
	minimum_positioner_length = JOURNEYLOG_SCROLLBAR_POSITIONER_LENGTH,

	T.state_enabled {
		journeylog_vscroll_canvas({})
	},
	T.state_disabled {
		T.draw {}
	},
	T.state_pressed {
		journeylog_vscroll_canvas({
			groove_color = JOURNEYLOG_SCROLLBAR_GROOVE_COLOR_HOVER,
			slider_color = JOURNEYLOG_SCROLLBAR_SLIDER_COLOR_HOVER
		})
	},
	T.state_focused {
		journeylog_vscroll_canvas({
			groove_color = JOURNEYLOG_SCROLLBAR_GROOVE_COLOR_HOVER,
			slider_color = JOURNEYLOG_SCROLLBAR_SLIDER_COLOR_HOVER
		})
	}
})

G_widget("tree_view", "naia_journeylog_viewer", {
	min_width         = 0,
	min_height        = 0,
	default_width     = 0,
	default_height    = 0,
	max_width         = 0,
	max_height        = 0,

	text_font_size    = 0,
	text_font_style   = "",

	T.state_enabled { T.draw {} },
	T.state_disabled { T.draw {} },

	T.grid {
		T.row {
			grow_factor = 1,
			T.column {
				grow_factor = 1,
				horizontal_grow = true,
				vertical_grow = true,
				T.grid {
					id = "_content_grid"
				}
			},
			T.column {
				grow_factor = 0,
				vertical_grow = true,
				T.grid {
					id = "_vertical_scrollbar_grid",
					T.row {
						grow_factor = 1,
						T.column {
							vertical_grow = true,
							border = "left",
							border_size = 3,
							T.vertical_scrollbar {
								id = "_vertical_scrollbar",
								definition = "naia_journeylog_viewer_vscroll"
							}
						}
					}
				}
			}
		},
		T.row {
			grow_factor = 0,
			T.column {
				horizontal_grow = true,
				T.grid {
					id = "_horizontal_scrollbar_grid",
					T.row {
						T.column {
							grow_factor = 1,
							horizontal_grow = true,
							border = "top",
							border_size = 3,
							T.horizontal_scrollbar {
								id = "_horizontal_scrollbar",
								definition = "naia_journeylog_viewer_hscroll"
							}
						}
					}
				}
			},
			T.column {
				T.spacer {}
			}
		}
	}
})
