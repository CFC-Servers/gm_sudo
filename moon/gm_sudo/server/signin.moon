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

        passesValidations = super(target) == true
        validPassword = @_verifyPassword target, net.ReadString!

        Logger\debug passesValidations, validPassword

        isValid = passesValidations and validPassword

        return @onSuccess and @onSuccess target if isValid

        @onFailedAttempt target
        @start target

SignInManager!
