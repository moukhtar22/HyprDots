-- ══════════════════════════════════════════════════════════════
--                   VARIABLES & AUTOSTART
--                 github.com/pahasara/HyprDots
-- ══════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────────────────────────
-- Autostart Programs
-- ──────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
  hl.exec_cmd("kbuildsycoca6 --noincremental || dunstify -u critical 'Failed to rebuild KService cache'")
  hl.exec_cmd("uwsm-app -t service -- kitty")
  hl.exec_cmd("uwsm-app -t service -s b -- ianny || dunstify -a warning 'Failed to start ianny service'")
  -- hl.exec_cmd("/home/shinzo/.local/bin/sound-alert --startup")
  -- hl.exec_cmd("uwsm-app -t service -s b -- hyprsnow || dunstify -a warning 'Failed to start hyprsnow service'")
end)
