local CreateFont
CreateFont = surface.CreateFont
local Logger
Logger = Sudo.Logger
CreateFont("GmodSudo_SudoPasswordFont", {
  font = "DermaLarge",
  size = 48
})
CreateFont("GmodSudo_SudoStandardFont", {
  font = "DermaLarge",
  size = 24
})
local NetMessages = include("gm_sudo/shared/net_messages.lua")
include("elements/sudo_panel.lua")
local lastRequest = os.time()
local requestSudo
requestSudo = function()
  Logger:debug("Requesting Sudo access!")
  if os.time() < lastRequest + 10 then
    return 
  end
  net.Start(NetMessages.signInStart)
  net.SendToServer()
  lastRequest = os.time()
end
return concommand.Add("sudo", requestSudo)
