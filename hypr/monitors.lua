-- Kanshi applies machine-specific monitor profiles after startup. This rule is
-- a safe fallback for outputs that are not covered by a Kanshi profile.
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

hl.config({
  xwayland = {
    enabled = true,
    force_zero_scaling = true,
  },
})
