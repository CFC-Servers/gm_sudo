import GetBySteamID from player
import Logger from Sudo

NetMessages = include "gm_sudo/shared/net_messages.lua"

for _, message in pairs NetMessages
    util.AddNetworkString message

Sudo =
    SignUpManager: include "signup.lua"
    SignInManager: include "signin.lua"
    Manager: include "gm_sudo/shared/sudo_manager.lua"

-- SignInManager --
Sudo.SignInManager.onFailedAttempt = (target) =>
    Logger\debug "SignInManager failed attempt"
    hook.Run "GmodSudo_FailedSignInAttempt", target

Sudo.SignInManager.onSuccess = (target) =>
    Logger\debug "SignInManager success, creating new SudoManager instance"
    hook.Run "GmodSudo_SuccessfulSignIn", target

    Sudo.Manager\add target

    net.Start NetMessages.signInSuccess
    net.Send target

    net.Start NetMessages.addSudoPlayer
    net.WriteEntity target
    net.Broadcast!

    hook.Run "GmodSudo_PostPlayerSignin", target

Sudo.SignInManager.onFailure = (target, message) =>
    Logger\info "SignIn failure for #{target}"
    hook.Run "GmodSudo_FailedSignIn", target, message

    net.Start NetMessages.signInFailure
    net.WriteString message
    net.Send target

-- SignUpManager --
Sudo.SignUpManager.onFailedAttempt = (target) => Logger\debug "SignUpManager failed attempt"

Sudo.SignUpManager.onSuccess = (target) =>
    Logger\info "SignUp success for #{target}"

    net.Start NetMessages.signUpSuccess
    net.Send target

Sudo.SignUpManager.onFailure = (target, message) =>
    Logger\info "SignUp failure for #{target}"

    net.Start NetMessages.signUpFailure
    net.WriteString message
    net.Send target

-- Interface --
net.Receive NetMessages.signInStart, (_, ply) ->
    result = hook.Run "GmodSudo_PlayerSignInRequest", ply
    return if result == false

    Logger\debug "Received sign in request, creating new SignInManager instance"

    Sudo.SignInManager\start ply

concommand.Add "sudoadd", (ply, cmd, args) ->
    return if IsValid ply

    steamId = args[1]
    target = GetBySteamID steamId

    Sudo.SignUpManager\start target
