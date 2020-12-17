import Logger from Sudo

ExchangeManager = include "lib/exchange_manager.lua"
Encryption = include "encryption.lua"
UserStorage = include "storage.lua"

networkMessage = "GmodSudo_SignIn"
util.AddNetworkString networkMessage

class SignInManager extends ExchangeManager
    new: =>
        super!
        @sessionLifetime = 60
        @promptMessage = networkMessage
        @_createListener!

    _timerName: (target) =>
        "GmodSudo_SignInTimeout_#{target}"

    _verifyPassword: (password, target) =>
        Logger\debug "Verifying password in SignInManager"

        target = target\SteamID64!
        data = UserStorage\get target

        Encryption\verify(
            password,
            data.digest,
            data.salt
        )

    receiveResponse: (target) =>
        Logger\debug "Received response in SignInManager"
        super!

        if not @_verifyPassword target, net.ReadString!
            -- TODO: Some alert here
            return @start target

        @onSuccess and @onSuccess target

SignInManager!
