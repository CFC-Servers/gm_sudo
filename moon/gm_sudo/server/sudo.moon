import GetBySteamID from player
import Logger from Sudo

NetMessages =
    signInRequest: "GmodSudo_RequestSignIn"
    signInSuccess: "GmodSudo_SignInSuccess"
    addSudoPlayer: "GmodSudo_AddSudoPlayer"

util.AddNetworkString NetMessages.signInRequest
util.AddNetworkString NetMessages.signInSuccess
util.AddNetworkString NetMessages.addSudoPlayer

Sudo =
    SignUpManager: include "signup.lua"
    SignInManager: include "signin.lua"
    Manager: include "gm_sudo/sudo_manager.lua"

-- SignInManager --
Sudo.SignInManager.onSuccess = (target) =>
    Logger\debug "SignInManager success, creating new SudoManager instance"

    Sudo.Manager\add target

    net.Start NetMessages.signInSuccess
    net.Send target

    net.Start NetMessages.addSudoPlayer
    net.WriteEntity target
    net.Broadcast!

Sudo.SignInManager.onFailedAttempt = (target) => Logger\debug "SignInManager failed attempt"

-- SignUpManager --
Sudo.SignUpManager.onSuccess = (target) => Logger\info "SignUp success!"
Sudo.SignUpManager.onFailedAttempt = (target) => Logger\debug "SignUpManager failed attempt"

-- Interface --
net.Receive NetMessages.signInRequest, (_, ply) ->
    Logger\debug "Received sign in request, creating new SignInManager instance"

    Sudo.SignInManager\start ply

concommand.Add "sudoadd", (ply, cmd, args) ->
    return if IsValid ply

    steamId = args[1]
    target = GetBySteamID steamId

    Sudo.SignUpManager\start target
