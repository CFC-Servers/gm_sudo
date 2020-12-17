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

    AddCSLuaFile "client/init.lua"
    AddCSLuaFile "client/prompt.lua"
    AddCSLuaFile "client/elements/sudo_panel.lua"
    AddCSLuaFile "client/elements/loading_panel.lua"
    AddCSLuaFile "client/elements/attempt_display.lua"
    AddCSLuaFile "client/elements/password_input.lua"
    AddCSLuaFile "client/elements/time_display.lua"

if CLIENT
    include "client/init.lua"
