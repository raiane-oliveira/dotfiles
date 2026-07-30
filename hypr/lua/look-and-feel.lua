---------------------
--- LOOK AND FEEL ---
---------------------

hl.config({
	general = {
		gaps_in = 6,
		gaps_out = 15,

		border_size = 1,

		col = {
			active_border = "rgba(cbe3b3ee)",
			-- active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		-- Set to true enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 0.90,

		shadow = {
			enabled = true,
			range = 5,
			render_power = 3,
			-- color = "rgba(1a1a1aee)"
			color = "rgba(121212ee)",
		},

		-- # https://wiki.hypr.land/Configuring/Variables/#blur
		blur = {
			enabled = true,
			size = 5,
			passes = 3,

			vibrancy = 0.1696,
			new_optimizations = true,
			ignore_opacity = false,
		},
	},

	-- https://wiki.hypr.land/Configuring/Variables/#animations
	animations = {
		enabled = true,
	},

	-- Ref https://wiki.hypr.land/Configuring/Workspace-Rules/
	-- See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
	dwindle = {
		preserve_split = true, -- You probably want this
	},

	-- See https://wiki.hypr.land/Configuring/Master-Layout/ for more
	master = {
		new_status = "master",
	},

	-- https://wiki.hypr.land/Configuring/Variables/#misc
	misc = {
		force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
	},
	group = {
		col = {
			border_active = "rgba(cbe3b3ee)", -- antes: active_border
			-- border_active   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
			border_inactive = "rgba(595959aa)", -- antes: inactive_border
		},

		groupbar = {
			font_size = 11,
			gradients = true,

			col = {
				active = "0xff323d43",
				inactive = "rgba(595959aa)",
			},

			rounding = 12,

			blur = false,

			indicator_gap = 4,
			indicator_height = 0,

			font_weight_active = "medium",
			font_weight_inactive = "medium",

			scrolling = false,
		},
	},
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
-- hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
-- hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
-- hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
-- hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "once" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "wind" })

-- Overrides from hyprland-gui.conf (HyprMod)
hl.config({
	decoration = {
		inactive_opacity = 0.98,
		blur = {
			enabled = false,
		},
	},
})
