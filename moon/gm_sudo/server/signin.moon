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
        @_createThrottleTimer!

    _timerName: (target) =>
        "GmodSudo_SignInTimeout_#{target\SteamID64!}"

    _verifyPassword: (target, password) =>
        Logger\info "Verifying password in SignInManager for #{target}"

        target = target\SteamID64!
        data = UserStorage\get target

        Encryption\verify(
            password,
            data.digest,
            data.salt
        )

    receiveResponse: (target) =>
        Logger\info "Received response in SignInManager for #{target}"

        passesValidations = super(target) == true

        if passesValidations
            validPassword = @_verifyPassword target, net.ReadString!

            Logger\debug "Passes validations"

            if validPassword
                Logger\info "Given a valid password, allowing access to #{target}"
                @remove target

                return @onSuccess target

        Logger\warn "Validations did not pass or given password was incorrect, failed attempt"

        @onFailedAttempt target
        @start target

SignInManager!
