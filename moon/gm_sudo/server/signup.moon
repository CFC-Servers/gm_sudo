SessionManager = require "lib/exchange_manager.lua"
Encryption = require "encryption.lua"
UserStorage = require "storage.lua"

networkMessage = "GmodSudo_SignUp"
util.AddNetworkString networkMessage

class SignUpManager extends SessionManager
    new: (signUpSuccess) =>
        super!
        @sessionLifetime = 180
        @promptMessage = networkMessage
        @onSuccess = signUpSuccess
        @_createListener!

    _timerName: (target) =>
        "GmodSudo_SignUpTimeout_#{target}"

    receiveResponse: (target) =>
        super!
        digest = Encryption\digest net.ReadString!
        -- TODO: some verification here
        Storage\store target\SteamID64!, digest

        @onSuccess target

SignUpManager!
