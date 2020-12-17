import Logger from Sudo

ExchangeManager = include "lib/exchange_manager.lua"
Encryption = include "encryption.lua"
UserStorage = include "storage.lua"

networkMessage = "GmodSudo_SignUp"
util.AddNetworkString networkMessage

class SignUpManager extends ExchangeManager
    new: =>
        super!
        @sessionLifetime = 180
        @promptMessage = networkMessage
        @_createListener!

    _timerName: (target) =>
        "GmodSudo_SignUpTimeout_#{target}"

    receiveResponse: (target) =>
        Logger\debug "Received response in SignUpManager"

        super target
        digest, salt = Encryption\digest net.ReadString!

        -- TODO: some verification here
        Storage\store target\SteamID64!, digest, salt

        @onSuccess and @onSuccess target

SignUpManager!
