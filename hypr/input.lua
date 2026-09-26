hl.config({
  input = {
    kb_layout = "us,ru",
    kb_variant = "",
    kb_model = "",
    kb_options = "grp:ctrl_space_toggle",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
    },
  },
})

hl.device({
  name = "synaptics-tm3276-022",
  natural_scroll = true,
  clickfinger_behavior = true,
})
