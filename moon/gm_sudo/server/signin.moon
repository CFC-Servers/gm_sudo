import Logger from Sudo

ExchangeManager = include "lib/exchange_manager.lua"
Encryption = include "encryption.lua"
UserStorage = include "storage.lua"
NetMessages = include "gm_sudo/shared/net_messages.lua"

class SignInManager extends ExchangeManager
    new: =>
        super!
        @sessionLifetime = 60
        @promptMessage = NetMessages.signInRequest
        @_createListener!

    _timerName: (target) =>
        "GmodSudo_SignInTimeout_#{target\SteamID64!}"

    _verifyPassword: (target, password) =>
        Logger\debug "Verifying password in SignInManager for #{target}"

        target = target\SteamID64!
        data = UserStorage\get target

        Encryption\verify(
            password,
            data.digest,
            data.salt
        )

    receiveResponse: (target) =>
        Logger\debug "Received response in SignInManager for #{target}"

        -- should we pcall this or something?
        passesValidations = super(target) == true
        validPassword = @_verifyPassword target, net.ReadString!

        Logger\debug passesValidations, validPassword

        isValid = passesValidations and validPassword

        if isValid
            @remove target
            return @onSuccess target

        @onFailedAttempt target
        @start target

SignInManager!
