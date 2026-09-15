-- Hyprland Lua configuration.
-- https://wiki.hypr.land/configuring/core/

------------------
---- MONITORS ----
------------------

hl.monitor({
    output = "DP-2",
    mode = "3440x1440@100",
    position = "0x0",
    scale = 1,
    bitdepth = 10,
})

hl.monitor({
    output = "DP-3",
    mode = "1920x1080@144",
    position = "3440x0",
    scale = 1,
    bitdepth = 10,
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "kitty yazi"
local menu = "rofi -show drun"
local web = "flatpak run app.zen_browser.zen"
local mail = "flatpak run eu.betterbird.Betterbird"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
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
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },

    input = {
        kb_layout = "us, tr",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:alt_shift_toggle, ctrl:nocaps",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },

    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    },
})

hl.curve("myBezier", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

----------------
---- INPUT -----
----------------

local mainMod = "SUPER"

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind("ALT + SHIFT + E", hl.dsp.exec_cmd("bemoji"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("rofi-rbw"))

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(web))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(mail))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\""))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "down" }))

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = 10, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = -10, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }))

hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 10, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = -10, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 0, y = 10, relative = true }))

hl.bind("SUPER + comma", hl.dsp.focus({ monitor = "-1" }))
hl.bind("SUPER + period", hl.dsp.focus({ monitor = "+1" }))
hl.bind("SUPER + SHIFT + comma", hl.dsp.window.move({ monitor = "-1" }))
hl.bind("SUPER + SHIFT + period", hl.dsp.window.move({ monitor = "+1" }))
hl.bind("SUPER + SHIFT + comma", hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind("SUPER + SHIFT + period", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind("SUPER + comma", hl.dsp.focus({ monitor = "0" }))
hl.bind("SUPER + period", hl.dsp.focus({ monitor = "1" }))

hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + P", hl.dsp.window.pseudo())

local zoomIn = "hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
local zoomOut = "hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
local resetZoom = "hyprctl -q keyword cursor:zoom_factor 1"

hl.bind(mainMod .. " + mouse_down", hl.dsp.exec_cmd(zoomIn))
hl.bind(mainMod .. " + mouse_up", hl.dsp.exec_cmd(zoomOut))
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd(zoomIn), { repeating = true })
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd(zoomOut), { repeating = true })
hl.bind(mainMod .. " + KP_ADD", hl.dsp.exec_cmd(zoomIn), { repeating = true })
hl.bind(mainMod .. " + KP_SUBTRACT", hl.dsp.exec_cmd(zoomOut), { repeating = true })
hl.bind(mainMod .. " + SHIFT + mouse_up", hl.dsp.exec_cmd(resetZoom))
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.exec_cmd(resetZoom))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.exec_cmd(resetZoom))
hl.bind(mainMod .. " + SHIFT + KP_SUBTRACT", hl.dsp.exec_cmd(resetZoom))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.exec_cmd(resetZoom))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = { 396, 205 },
    move = { 1500, 800 },
})
