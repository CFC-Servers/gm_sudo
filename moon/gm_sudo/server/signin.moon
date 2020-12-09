ExchangeManager = require "lib/exchange_manager.lua"
Encryption = require "encryption.lua"
UserStorage = require "storage.lua"

networkMessage = "GmodSudo_SignIn"
util.AddNetworkString networkMessage

class SignInManager extends ExchangeManager
    new: (signInSuccess) =>
        super!
        @sessionLifetime = 60
        @promptMessage = networkMessage
        @onSuccess = signInSuccess
        @_createListener!

    _timerName: (target) =>
        "GmodSudo_SignInTimeout_#{target}"

    _verifyPassword: (password, target) =>
        Encryption\verify(
            password,
            UserStorage\getDigest target\SteamID64!
        )

    receiveResponse: (target) =>
        super!

        if not @_verifyPassword target, net.ReadString!
            -- TODO: Some alert here
            return @start target

        @signInSuccess target

SignInManager!
