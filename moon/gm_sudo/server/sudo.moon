import GetBySteamID from player

import Logger from Sudo

NetMessages =
    signInRequest: "GmodSudo_RequestSignIn"
    signInSuccess: "GmodSudo_SignInSuccess"

util.AddNetworkString NetMessages.signInRequest
util.AddNetworkString NetMessages.signInSuccess

class SudoManager
    new: (ply, duration=30*60) =>
        Logger\debug "New Sudo session for #{ply\SteamID64!}"

        @ply = ply
        @duration = duration
        @wrapSuperadmin!

    wrapSuperadmin: =>
        Logger\debug "Wrapping superadmin for #{@ply\SteamID64!}"

        expiration = os.time! + @duration
        Logger\debug "Expiration: #{expiration}"

        @originalSuperadmin = @ply.IsSuperAdmin
        Logger\debug "Original Superadmin: #{@originalSuperadmin}"

        @ply.IsSuperAdmin = ->
            Logger\debug "Calling wrapped IsSuperAdmin"

            now = os.time!
            return true unless now >= expiration

            Logger\debug "Time expired, unwrapping IsSuperAdmin"

            @ply.IsSuperAdmin = @originalSuperadmin

            Logger\debug "Unwrapped and reverted IsSuperAdmin to #{@ply.IsSuperAdmin}"

            original = @originalSuperadmin
            ply = @ply

            Sudo.Sessions[ply] = nil

            return original(ply)

        Logger\debug "Wrapped IsSuperAdmin. Is: #{@ply.IsSuperAdmin} | Was: #{@originalSuperadmin}"

Sudo =
    SignUpManager: include "signup.lua"
    SignInManager: include "signin.lua"
    Sessions: {}

-- SignInManager
Sudo.SignInManager.onSuccess = (target) =>
    Logger\debug "SignInManager success, creating new SudoManager instance"

    Sudo.Sessions[target] = SudoManager target

    net.Start NetMessages.signInSuccess
    net.Send target

Sudo.SignInManager.onFailedAttempt = (target) =>
    Logger\debug "SignInManager failed attempt"

-- SignUpManager
Sudo.SignUpManager.onSuccess = (target) =>
    Logger\info "SignUp success!"

Sudo.SignUpManager.onFailedAttempt = (target) =>
    Logger\debug "SignUpManager failed attempt"

-- Interface
net.Receive NetMessages.signInRequest, (_, ply) ->
    Logger\debug "Received sign in request, creating new SignInManager instance"

    Sudo.SignInManager\start ply, ply

concommand.Add "sudoadd", (ply, cmd, args) ->
    return if IsValid ply

    steamId = args[1]
    target = GetBySteamID steamId

    Sudo.SignUpManager\start "Console", target
