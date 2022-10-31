AddCSLuaFile!

export Sudo = {}

if file.Exists "includes/modules/logger.lua", "LUA"
    require "logger"
    Sudo.Logger = Logger "Sudo"
else
    log = (level) ->
        (_, ...) ->
            print "[GmodSudo] ", "[#{level}]", ...

    Sudo.Logger =
        trace: log "trace"
        debug: log "debug"
        info: log "info"
        warn: log "warn"
        error: error
        fatal: error

    Sudo.Logger\warn "GM_Logger not found, using fallback logger."
    Sudo.Logger\warn "Consider installing: github.com/CFC-Servers/gm_logger"

if SERVER
    include "gm_sudo/server/init.lua"

    AddCSLuaFile "gm_sudo/shared/sudo_manager.lua"
    AddCSLuaFile "gm_sudo/shared/net_messages.lua"

    AddCSLuaFile "gm_sudo/client/init.lua"
    AddCSLuaFile "gm_sudo/client/sudo.lua"
    AddCSLuaFile "gm_sudo/client/prompt.lua"
    AddCSLuaFile "gm_sudo/client/elements/sudo_panel.lua"
    AddCSLuaFile "gm_sudo/client/elements/status_panel.lua"
    AddCSLuaFile "gm_sudo/client/elements/attempt_display.lua"
    AddCSLuaFile "gm_sudo/client/elements/password_input.lua"
    AddCSLuaFile "gm_sudo/client/elements/time_display.lua"

    resource.AddSingleFile "materials/gm_sudo/success.png"
    resource.AddSingleFile "materials/gm_sudo/hourglass.png"
    resource.AddSingleFile "sound/gm_sudo/access_granted.mp3"

if CLIENT
    include "gm_sudo/client/init.lua"
