hl.on("hyprland.start", function ()
    hl.exec_cmd("discord")
    hl.exec_cmd("steam")
end)

local status, smw = pcall(require, "plugins.split-monitor-workspaces")
if status then
    smw.setup({
        workspace_count = 9,
        monitor_priority = {"DP-2", "DP-1"},
    })
end

hl.window_rule({
    match = { class = "discord" },
    workspace = "18 silent",
})

hl.window_rule({
    match = { class = "steam" },
    workspace = "9 silent",
})
hl.window_rule({
    match = { title = "Steam" },
    workspace = "9 silent",
})
