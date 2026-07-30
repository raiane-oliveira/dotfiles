-----------------
--- AUTOSTART ---
-----------------

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd('hyprctl setcursor "everforest-cursors-light" 30')
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("waybar")
	hl.exec_cmd("swaync")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("wl-clip-persist --clipboard regular")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("rclone mount gdrive: ~/GoogleDrive --vfs-cache-mode writes")
	hl.exec_cmd("pika-backup --gapplication-service")

	hl.exec_cmd("hypridle")

	-- OSD server
	hl.exec_cmd("swayosd-server")
end)
