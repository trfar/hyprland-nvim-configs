-- Silence the lua language server's "hl undefined" warnings
---@diagnostic disable: undefined-global

------------------------
---- MACHINE .env ----
------------------------
-- Optional hypr/.env (KEY=VALUE, # comments) loaded from the directory this
-- file was started from (see .env.example). Missing file or key -> the
-- default shown here, so a machine without a .env keeps working as before.
local function configDir()
	local src = debug.getinfo(1, "S").source:match("^@?(.*)$")
	local dir = src:match("^(.+)/[^/]+$")
	if dir and #dir > 0 then return dir end
	local home = os.getenv("HOME") or ""
	local xdg = os.getenv("XDG_CONFIG_HOME")
	return (xdg and xdg ~= "" and xdg or home .. "/.config") .. "/hypr"
end

local env = {}
local function loadEnv(path)
	local f = io.open(path)
	if not f then return end
	for line in f:lines() do
		if not line:match("^%s*#") then
			local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
			if k then env[k] = v end
		end
	end
	f:close()
end
loadEnv(configDir() .. "/.env")
-- .env value, or nil if the key is missing/empty; caller decides the fallback.
local function envVal(key)
	local v = env[key]
	return (v and v ~= "") and v or nil
end

------------------
---- MONITORS ----
------------------
-- monitors.lua holds this machine's per-monitor resolution/position/rotation
-- and is loaded only if it exists; without it Hyprland auto-detects monitors
-- (fine for a single built-in display).
do
	local f = io.open(configDir() .. "/monitors.lua")
	if f then
		f:close()
		require("monitors")
	end
end

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = envVal("TERMINAL") or "alacritty"
local fileManager = envVal("FILEMANAGER") or "/home/trfar/.local/bin/strata"
local menu = envVal("MENU") or "fuzzel"
local lockscreen = "hyprlock"
local browser = envVal("BROWSER") or "zen-browser"
local obsidian = envVal("OBSIDIAN") or "obsidian --disable-gpu"
local idle_daemon = "hypridle"
local wallpaper_daemon = "swaybg"

local PRIMARY = envVal("PRIMARY_MONITOR") or "DP-1" -- main monitor, scrolling
-- Explicit empty SECONDARY_MONITOR in .env = single-monitor setup;
-- a machine with no .env key keeps the dual layout.
local SECONDARY = (env["SECONDARY_MONITOR"] ~= nil) and env["SECONDARY_MONITOR"] or "DP-2"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	local wp1 = env["WALLPAPER_PRIMARY"] or "/home/trfar/Pictures/Wallpapers/Active.png"
	if wp1 ~= "" then
		hl.exec_cmd(wallpaper_daemon .. " -o " .. PRIMARY .. " -i " .. wp1)
	end
	local wp2 = env["WALLPAPER_SECONDARY"] or "/home/trfar/Pictures/Wallpapers/Active-Cropped.png"
	if SECONDARY ~= "" and wp2 ~= "" then
		hl.exec_cmd(wallpaper_daemon .. " -o " .. SECONDARY .. " -i " .. wp2)
	end
	hl.exec_cmd(idle_daemon)
	hl.exec_cmd(lockscreen)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 0,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(ff3333ff)", "rgba(ff9900ff)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = true,

		-- Global default. The left monitor's workspaces override this below.
		layout = "scrolling",
	},

	scrolling = {
		-- A single window fills the monitor
		fullscreen_on_one_column = true,

		-- Default width of new columns
		column_width = 0.5,

		-- Bring focused columns fully into view
		focus_fit_method = 1,

		-- Automatically follow focused windows
		follow_focus = 1,

		-- How much of a window must remain visible
		follow_min_visible = 0.4,

		-- Useful predefined column widths (cycled with SUPER + R)
		explicit_column_widths = "0.333, 0.5, 0.667, 1.0",

		-- Cycle around the scrolling workspace
		wrap_focus = true,
		wrap_swapcol = true,

		-- New windows appear to the right
		direction = "right",
	},

	-- Used by the left monitor's workspaces
	master = {
		-- Big window on top, new windows join the stack below it
		new_status = "slave",
		mfact = 0.6,
		orientation = "top",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 0.92,

		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

----------------
----  MISC  ----
----------------
hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

---------------
---- INPUT ----
---------------
hl.config({
	input = {
		kb_layout = "us",
		follow_mouse = 1,
		touchpad = {
			natural_scroll = false,
		},
	},
})

----------------------------------------
---- WORKSPACES (PER-MONITOR LAYOUT) ----
----------------------------------------
-- Dual monitor:  workspaces 1-5 -> PRIMARY, scrolling
--                workspaces 6-10 -> SECONDARY, master layout, big window on top
-- Single monitor (SECONDARY_MONITOR empty): all 1-10 on the one monitor, scrolling
if SECONDARY == "" then
	for i = 1, 10 do
		hl.workspace_rule({
			workspace = tostring(i),
			layout = "scrolling",
			default = (i == 1),
			persistent = (i == 1),
		})
	end
else
	for i = 1, 5 do
		hl.workspace_rule({
			workspace = tostring(i),
			monitor = PRIMARY,
			layout = "scrolling",
			default = (i == 1),
			persistent = (i == 1),
		})
	end

	for i = 6, 10 do
		hl.workspace_rule({
			workspace = tostring(i),
			monitor = SECONDARY,
			layout = "master",
			layout_opts = { orientation = "top" },
			default = (i == 6),
			persistent = (i == 6),
		})
	end
end

-- Terminal scratchpad
hl.on("workspace.created", function(ws)
	if ws.name == "special:term" and ws.is_empty then
		hl.exec_cmd(terminal)
	end
end)

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Apps
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.workspace.toggle_special("term"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + tab", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(obsidian))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))

-- Window basics
hl.bind(mainMod .. " + grave", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Screen snip
hl.bind(mainMod .. " + SHIFT + c", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Lock / shutdown
-- (Lock moved off SUPER+SHIFT+L, which is now "move window right")
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd(lockscreen))
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
)

-- Focus (vim keys). Crosses between monitors at the edge of a workspace.
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move window within the layout
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Send window to the other monitor (and follow it)
hl.bind(mainMod .. " + ALT + h", hl.dsp.window.move({ monitor = "l", follow = true }))
hl.bind(mainMod .. " + ALT + l", hl.dsp.window.move({ monitor = "r", follow = true }))

-- Scrolling layout controls (right monitor)
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col")) -- scroll view right
hl.bind(mainMod .. " + comma", hl.dsp.layout("move -col")) -- scroll view left
hl.bind(mainMod .. " + CTRL + h", hl.dsp.layout("swapcol l")) -- swap column left
hl.bind(mainMod .. " + CTRL + l", hl.dsp.layout("swapcol r")) -- swap column right
hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf")) -- cycle column widths
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("consume_or_expel prev")) -- merge into / split out of column
hl.bind(mainMod .. " + bracketright", hl.dsp.layout("consume_or_expel next"))

-- Master layout controls (left monitor)
hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster")) -- promote focused window to the big slot
hl.bind(mainMod .. " + O", hl.dsp.layout("orientationnext")) -- cycle top/right/bottom/left

-- Workspaces: SUPER + 1-5 = right monitor, SUPER + 6-0 = left monitor (0 = workspace 10)
-- SUPER + SHIFT + number sends the focused window to that workspace
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
	-- Ignore maximize requests from all apps.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
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

	move = "20 monitor_h-120",
	float = true,
})
