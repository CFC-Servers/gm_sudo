if SERVER
    include "server/init.lua"

    AddCSLuaFile "client/init.lua"
    AddCSLuaFile "client/prompt.lua"
    AddCSLuaFile "client/elements/attempt_display.lua"
    AddCSLuaFile "client/elements/password_input.lua"
    AddCSLuaFile "client/elements/time_display.lua"

if CLIENT
    include "client/init.lua"
