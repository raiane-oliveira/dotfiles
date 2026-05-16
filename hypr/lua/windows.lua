-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = { "20", "monitor_h-120" },
	float = true,
})

-- Initialize apps on workspaces
hl.window_rule({ match = { initial_class = "^(spotify)$" }, workspace = 3 })

-- Floating windows apps
hl.window_rule({ match = { class = "clipse" }, float = true, size = { 622, 652 } })
hl.window_rule({ match = { class = "clipse-gui" }, float = true, size = { 622, 652 } })
hl.window_rule({ match = { class = "nwg-look" }, float = true, size = { 822, 682 } })

hl.window_rule({ match = { class = "nm-connection-editor" }, float = true, size = { 822, 682 } })
hl.window_rule({ match = { class = "blueman-manager" }, float = true, size = { 822, 682 } })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true, size = { 822, 682 } })
hl.window_rule({ match = { class = "^(com.gabm.satty)$" }, float = true, size = { 822, 682 } })
