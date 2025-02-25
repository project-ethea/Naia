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

local JOURNEYLOG_PANEL_PADDING = 3

local JOURNEYLOG_PANEL_BORDER_COLOR = "114, 79, 46, 127" -- GUI__BORDER_COLOR_DARK

-- Canvas definition WML

gui.add_widget_definition("window", "naia_campaign_intro", {
	id = "naia_campaign_intro",
	description = "Campaign intro billboard",

	T.resolution {
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
	}
})

gui.add_widget_definition("window", "naia_journeylog", {
	id = "naia_journeylog",
	description = "a decade and a half later, gui2 still sucks",

	T.resolution {
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
	}
})

gui.add_widget_definition("panel", "naia_journeylog_panel", {
	id = "naia_journeylog_panel",
	description = "a decade and a half later, gui2 still sucks",

	T.resolution {
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
				T.line {
					x1 = 1,
					y1 = 0,
					x2 = "(width - 2)",
					y2 = 0,
					thickness = 1,
					color = JOURNEYLOG_PANEL_BORDER_COLOR
				},
				T.line {
					x1 = 0,
					y1 = 1,
					x2 = 0,
					y2 = "(height - 2)",
					thickness = 1,
					color = JOURNEYLOG_PANEL_BORDER_COLOR
				},
				T.line {
					x1 = 1,
					y1 = "(height - 1)",
					x2 = "(width - 2)",
					y2 = "(height - 1)",
					thickness = 1,
					color = JOURNEYLOG_PANEL_BORDER_COLOR
				},
				T.line {
					x1 = "(width - 1)",
					y1 = 1,
					x2 = "(width - 1)",
					y2 = "(height - 2)",
					thickness = 1,
					color = JOURNEYLOG_PANEL_BORDER_COLOR
				},
			}
		},
		T.foreground {
			T.draw {}
		}
	}
})
