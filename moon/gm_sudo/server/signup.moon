import Logger from Sudo

ExchangeManager = include "lib/exchange_manager.lua"
Encryption = include "encryption.lua"
UserStorage = include "storage.lua"
NetMessages = include "gm_sudo/shared/net_messages.lua"

class SignUpManager extends ExchangeManager
    new: =>
        super!
        @sessionLifetime = 180
        @promptMessage = NetMessages.signUpRequest
        @_createListener!

    _timerName: (target) =>
        "GmodSudo_SignUpTimeout_#{target\SteamID64!}"

    receiveResponse: (target) =>
        Logger\debug "Received response in SignUpManager"

        super target
        digest, salt = Encryption\digest net.ReadString!

        -- TODO: some verification here
        UserStorage\store target\SteamID64!, digest, salt

        @remove target

        hook.Run "GmodSudo_PostPlayerSignUp"
        @onSuccess and @onSuccess target

    removeUser: (target) =>
        Logger\debug "Deleting: #{target}"
        res = UserStorage\delete target
        Logger\info "'#{target}' has been deleted"

        res

SignUpManager!
