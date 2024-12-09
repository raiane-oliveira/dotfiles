-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Background and fonts
config.font_size = 12
config.color_scheme = "mellow"
config.font = wezterm.font("JetBrains Mono Nerd Font")
config.background = {
	{
		source = {
			File = "/home/raianeeo/Pictures/Wallpapers/caitvi-cela.jpg",
		},
		horizontal_align = "Center",
	},
	{
		source = {
			Color = "#0c0605",
		},
		width = "100%",
		height = "100%",
		opacity = 0.6,
	},
}

-- Tab bar
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.default_cursor_style = "BlinkingBar"
-- config.window_decorations =

-- and finally, return the configuration to wezterm
return config
