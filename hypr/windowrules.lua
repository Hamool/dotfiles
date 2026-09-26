hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Prevent transient XWayland helper windows from stealing focus.
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

local workspace_rules = {
  { class = "^(kitty)$", workspace = 1 },
  { class = "^(firefox)$", workspace = 2 },
  { class = "^(zen)$", workspace = 2 },
  { class = "^(org.telegram.desktop)$", workspace = 3 },
  { class = "^(discord)$", workspace = 4 },
  { class = "^(mpv)$", workspace = 4 },
  { class = "^(org.gnome.Nautilus)$", workspace = 4 },
  { class = "^(org.qbittorrent.qBittorrent)$", workspace = 4 },
  { class = "^(steam)$", workspace = 5 },
  { class = "^(net.lutris.Lutris)$", workspace = 5 },
}

for index, rule in ipairs(workspace_rules) do
  hl.window_rule({
    name = "workspace-" .. index,
    match = { class = rule.class },
    workspace = rule.workspace,
  })
end

hl.window_rule({
  name = "float-by-class",
  match = { class = "^(floating|mpv)$" },
  float = true,
})
