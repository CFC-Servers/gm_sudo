AddCSLuaFile!
require "cfclogger"

export Sudo = {}

if CFCLogger
    Sudo.Logger = CFCLogger "Sudo"
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

if SERVER
    include "server/init.lua"

    AddCSLuaFile "shared/sudo_manager.lua"

    AddCSLuaFile "client/init.lua"
    AddCSLuaFile "client/prompt.lua"
    AddCSLuaFile "client/elements/sudo_panel.lua"
    AddCSLuaFile "client/elements/status_panel.lua"
    AddCSLuaFile "client/elements/attempt_display.lua"
    AddCSLuaFile "client/elements/password_input.lua"
    AddCSLuaFile "client/elements/time_display.lua"

    resource.AddSingleFile "materials/gm_sudo/success.png"
    resource.AddSingleFile "materials/gm_sudo/hourglass.png"
    resource.AddSingleFile "sound/gm_sudo/access_granted.mp3"

if CLIENT
    include "client/init.lua"
