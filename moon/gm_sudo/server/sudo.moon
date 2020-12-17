import GetBySteamID from player

import Logger from Sudo

util.AddNetworkString "GmodSudo_RequestSignIn"

class SudoManager
    new: (ply, duration=30*60) =>
        Logger\debug "New Sudo session for #{ply\SteamID64!}"

        @ply = ply
        @duration = duration
        @wrapSuperadmin!

    wrapSuperadmin: =>
        Logger\debug "Wrapping superadmin for #{@ply\SteamID64!}"

        expiration = os.time! + @duration
        @originalSuperadmin = @ply.IsSuperAdmin

        @ply.IsSuperAdmin = ->
            now = os.time!
            return true unless now >= expiration

            @ply.IsSuperAdmin = @originalSuperadmin
            return @originalSuperadmin @ply

Sudo =
    SignUpManager: include "signup.lua"
    SignInManager: include "signin.lua"

Sudo.SignInManager.onSuccess = (target) =>
    Logger\debug "SignInManager success, creating new SudoManager instance"

    SudoManager target

Sudo.SignUpManager.onSuccess = (target) =>
    Logger\info "SignUp success!"

net.Receive "GmodSudo_RequestSignIn", (_, ply) ->
    Logger\debug "Received sign in request, creating new SignInManager instance"

    Sudo.SignInManager\start ply, ply

concommand.Add "sudoadd", (ply, cmd, args) ->
    return if IsValid ply

    steamId = args[1]
    target = GetBySteamID steamId

    Sudo.SignUpManager\start "Console", target
