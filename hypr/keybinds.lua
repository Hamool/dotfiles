local main_mod = "SUPER"

local function bind(keys, dispatcher, options)
  hl.bind(keys, dispatcher, options)
end

-- Applications and session controls.
bind(main_mod .. " + Return", hl.dsp.exec_cmd("kitty"))
bind(main_mod .. " + SHIFT + Return", hl.dsp.exec_cmd("kitty --class floating"))
bind(main_mod .. " + SHIFT + W", hl.dsp.exec_cmd("zen-browser"))
bind(main_mod .. " + E", hl.dsp.exec_cmd("nautilus"))
bind(main_mod .. " + Space", hl.dsp.exec_cmd("wofi-catppucin"))
bind(main_mod .. " + W", hl.dsp.exec_cmd("pkill waybar; waybar"))
bind(main_mod .. " + X", hl.dsp.exec_cmd("wlogout"))
bind(main_mod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
bind(main_mod .. " + M", hl.dsp.exit())

-- Window management.
bind(main_mod .. " + C", hl.dsp.window.close())
bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
bind(main_mod .. " + F", hl.dsp.window.fullscreen())
bind(main_mod .. " + P", hl.dsp.window.pseudo())
bind(main_mod .. " + Tab", hl.dsp.window.cycle_next())
bind(main_mod .. " + H", hl.dsp.focus({ direction = "left" }))
bind(main_mod .. " + J", hl.dsp.focus({ direction = "down" }))
bind(main_mod .. " + K", hl.dsp.focus({ direction = "up" }))
bind(main_mod .. " + L", hl.dsp.focus({ direction = "right" }))

for workspace = 1, 10 do
  local key = workspace % 10
  bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

bind(main_mod .. " + CTRL + H", hl.dsp.focus({ workspace = "-1" }))
bind(main_mod .. " + CTRL + L", hl.dsp.focus({ workspace = "+1" }))
bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots.
bind("Print", hl.dsp.exec_cmd("hyprshot -m output"))
bind("ALT + Print", hl.dsp.exec_cmd("hyprshot -m window"))
bind(main_mod .. " + Print", hl.dsp.exec_cmd("hyprshot -m region"))

-- Media and brightness keys work while the session is locked.
local repeatable = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), repeatable)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), repeatable)
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), repeatable)
bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), repeatable)
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"), repeatable)
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), repeatable)

local locked = { locked = true }
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
