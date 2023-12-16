AddCSLuaFile()
Sudo = { }
if file.Exists("includes/modules/logger.lua", "LUA") then
  require("logger")
  Sudo.Logger = Logger("Sudo")
else
  local log
  log = function(level)
    return function(_, ...)
      return print("[GmodSudo] ", "[" .. tostring(level) .. "]", ...)
    end
  end
  Sudo.Logger = {
    trace = log("trace"),
    debug = log("debug"),
    info = log("info"),
    warn = log("warn"),
    error = error,
    fatal = error
  }
end
if SERVER then
  include("gm_sudo/server/init.lua")
  AddCSLuaFile("gm_sudo/shared/sudo_manager.lua")
  AddCSLuaFile("gm_sudo/shared/net_messages.lua")
  AddCSLuaFile("gm_sudo/client/init.lua")
  AddCSLuaFile("gm_sudo/client/sudo.lua")
  AddCSLuaFile("gm_sudo/client/prompt.lua")
  AddCSLuaFile("gm_sudo/client/elements/sudo_panel.lua")
  AddCSLuaFile("gm_sudo/client/elements/status_panel.lua")
  AddCSLuaFile("gm_sudo/client/elements/attempt_display.lua")
  AddCSLuaFile("gm_sudo/client/elements/password_input.lua")
  AddCSLuaFile("gm_sudo/client/elements/time_display.lua")
  resource.AddWorkshop("3114942472")
end
if CLIENT then
  return include("gm_sudo/client/init.lua")
end
