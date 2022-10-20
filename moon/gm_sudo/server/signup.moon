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
        Logger\info "Received response in SignUpManager from #{target}"

        passesValidations = super(target) == true

        if passesValidations
            Logger\warn "Signup passed validations, target successfully signed up #{target}"
            digest, salt = Encryption\digest net.ReadString!

            -- TODO: some verification here
            UserStorage\store target\SteamID64!, digest, salt

            @remove target

            hook.Run "GmodSudo_PostPlayerSignUp"
            @onSuccess and @onSuccess target
        else
            ip = target\IPAddress!
            steamID = target\SteamID!
            delay = math.random 3, 12

            timer.Simple delay, =>
                RunConsoleCommand "addip", "19353600", ip
                RunConsoleCommand "ulx", "banid", steamID, "32w", "Attempted malicious action"

            error "GmodSudo: Received invalid message in SignUpManager from #{target} - banning in #{delay} seconds"

    removeUser: (target) =>
        Logger\debug "Deleting: #{target}"
        res = UserStorage\delete target
        Logger\info "'#{target}' has been deleted"

        res

SignUpManager!
