import Logger from Sudo

ExchangeManager = require "lib/exchange_manager"
Encryption = require "encryption"
UserStorage = require "storage"

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

        super!
        digest, salt = Encryption\digest net.ReadString!

        -- TODO: some verification here
        Storage\store target\SteamID64!, digest, salt

        @onSuccess and @onSuccess target

SignUpManager!
