local GetBySteamID
GetBySteamID = player.GetBySteamID
local Logger
Logger = Sudo.Logger
local NetMessages = include("gm_sudo/shared/net_messages.lua")
for _, message in pairs(NetMessages) do
  util.AddNetworkString(message)
end
local Sudo = {
  SignUpManager = include("signup.lua"),
  SignInManager = include("signin.lua"),
  Manager = include("gm_sudo/shared/sudo_manager.lua")
}
Sudo.SignInManager.onFailedAttempt = function(self, target)
  Logger:debug("SignInManager failed attempt")
  return hook.Run("GmodSudo_FailedSignInAttempt", target)
end
Sudo.SignInManager.onSuccess = function(self, target)
  Logger:debug("SignInManager success, creating new SudoManager instance")
  hook.Run("GmodSudo_SuccessfulSignIn", target)
  Sudo.Manager:add(target)
  net.Start(NetMessages.signInSuccess)
  net.Send(target)
  net.Start(NetMessages.addSudoPlayer)
  net.WriteEntity(target)
  net.Broadcast()
  return hook.Run("GmodSudo_PostPlayerSignin", target)
end
Sudo.SignInManager.onFailure = function(self, target, message)
  Logger:info("SignIn failure for " .. tostring(target))
  hook.Run("GmodSudo_FailedSignIn", target, message)
  net.Start(NetMessages.signInFailure)
  net.WriteString(message)
  return net.Send(target)
end
Sudo.SignUpManager.onFailedAttempt = function(self, target)
  return Logger:debug("SignUpManager failed attempt")
end
Sudo.SignUpManager.onSuccess = function(self, target)
  Logger:info("SignUp success for " .. tostring(target))
  net.Start(NetMessages.signUpSuccess)
  return net.Send(target)
end
Sudo.SignUpManager.onFailure = function(self, target, message)
  Logger:info("SignUp failure for " .. tostring(target))
  net.Start(NetMessages.signUpFailure)
  net.WriteString(message)
  return net.Send(target)
end
net.Receive(NetMessages.signInStart, function(_, ply)
  local result = hook.Run("GmodSudo_PlayerSignInRequest", ply)
  if result == false then
    return 
  end
  Logger:debug("Received sign in request, creating new SignInManager instance")
  return Sudo.SignInManager:start(ply)
end)
concommand.Add("sudoadd", function(ply, cmd, args)
  if IsValid(ply) then
    return 
  end
  local steamId = args[1]
  local target = GetBySteamID(steamId)
  return Sudo.SignUpManager:start(target)
end)
return concommand.Add("sudoremove", function(ply, cmd, args)
  if IsValid(ply) then
    return 
  end
  local steamId = args[1]
  return Sudo.SignUpManager:removeUser(steamId)
end)
