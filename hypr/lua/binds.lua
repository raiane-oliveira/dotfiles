-------------------
--- MY PROGRAMS ---
-------------------

-- # See https://wiki.hypr.land/Configuring/Keywords/

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "~/.config/rofi/launchers/current || pkill rofi"
-- # $clipboard = ~/.config/rofi/launchers/type-6/clipboard.sh || pkill rofi
-- # $clipboard = kitty --class clipse -e 'clipse'
local clipboard = "clipse-gui"
local powermenu = "~/.config/rofi/powermenu/current || pkill rofi"
local browser = "brave"
local screenshot = "hyprshot -m region --freeze --raw | swappy -f -"
-- # $screenshot = grim -g "$(slurp)" - | swappy -f -
local playerctl = "~/.config/rofi/applets/bin/playerctl.sh || pkill rofi"
local pkgmanager = "~/.config/rofi/applets/bin/pkgmanager.sh menu || pkill rofi"
local miselang = "~/.config/rofi/applets/bin/mise-lang.sh menu || pkill rofi"
local editconfigs = "~/.config/rofi/applets/bin/dotfiles-edit-menu.sh || pkill rofi"
local setwallpaper = "~/.config/rofi/applets/bin/wallpapers.sh || pkill rofi"
local raianeflix = "~/.config/rofi/applets/bin/raianeflix.sh || pkill rofi"

-------------------
--- KEYBINDINGS ---
-------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(
	mainMod .. " + ALT + M",
	hl.dsp.exec_cmd('command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch "hl.dsp.exit()"')
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("flatpak run com.spotify.Client"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + 0", hl.dsp.exec_cmd("hyprpicker --autocopy -n"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("brave --app=https://www.notion.so"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("brave --app=https://www.claude.ai"))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + CTRL + Space", hl.dsp.exec_cmd("handy --toggle-transcription --start-hidden"))
hl.bind(mainMod .. " + CTRL + SHIFT + Space", hl.dsp.exec_cmd("pkill -9 handy"))

-- Opens HyprQuickFrame - Decided on-the-fly whether to Edit, Save, or Copy
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot))
hl.bind("PRINT", hl.dsp.exec_cmd(screenshot))

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/scripts/toggle_wayscriber.sh"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("pkill -9 wayscriber"))

-- Rofi
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(powermenu))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(clipboard))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(playerctl))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(pkgmanager))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(miselang))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("[float] " .. editconfigs))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(setwallpaper))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("[float] " .. raianeflix))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/.config/rofi/applets/bin/change-waybar.sh || pkill rofi"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

-- Move focus with mainMod + hjkl (vim style)
hl.bind(mainMod .. " + CTRL + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.focus({ direction = "down" }))

-- Atalhos para trocar a posição das janelas (swap)
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "d" }))

-- Resize active window
hl.bind(
	mainMod .. " + CTRL + SHIFT + l",
	hl.dsp.window.resize({ x = 25, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + SHIFT + h",
	hl.dsp.window.resize({ x = -25, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + SHIFT + k",
	hl.dsp.window.resize({ x = 0, y = -25, relative = true }),
	{ repeating = true }
)
hl.bind(
	mainMod .. " + CTRL + SHIFT + j",
	hl.dsp.window.resize({ x = 0, y = 25, relative = true }),
	{ repeating = true }
)

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

-- Grupos de janelas
hl.bind(mainMod .. " + TAB", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev())

hl.bind("ALT + SHIFT + l", hl.dsp.group.move_window({ direction = "f" }))
hl.bind("ALT + SHIFT + h", hl.dsp.group.move_window({ direction = "b" }))
hl.bind("ALT + k", hl.dsp.window.move({ out_of_group = "up" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end
-- hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
-- hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + CTRL + SHIFT + left", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- -----------------------------------------------
-- Teclas multimídia do laptop — volume e brilho
-- repeating = true  →  equivalente ao 'e' de bindel
-- locked    = true  →  equivalente ao 'l' de bindel/bindl (funciona na tela de bloqueio)
-- -----------------------------------------------
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("swayosd-client --brightness raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("swayosd-client --brightness lower"),
	{ locked = true, repeating = true }
)

-- -----------------------------------------------
-- Media Player — locked = true para funcionar na tela de bloqueio (sem repetição)
-- -----------------------------------------------
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl previous"), { locked = true })

-- hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
-- hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
-- hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true, repeating = true })
-- hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })

-- Requires playerctl
-- hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
-- hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
