import Base64Encode from util
import Logger from Sudo

Random = include "gm_sudo/server/random.lua"

class ExchangeManager
    new: =>
        @sessions = {}
        @maxAttempts = 3
        @tokenSize = 32
        @sessionLifetime = 120
        @promptMessage = nil

    _createListener: =>
        Logger\debug "Creating net listener for: #{@promptMessage}"

        net.Receive @promptMessage, (_, ply) ->
            @receiveResponse ply

    _timerName: (target) =>
        error "NotImplemented"

    _generateToken: => Base64Encode Random.bytes @tokenSize

    _createRemovalTimer: (target) =>
        Logger\debug "Creating removal timer for: #{target}"

        timer.Create @_timerName(target), @sessionLifetime, 1, ->
            @remove target

    _stopRemovalTimer: (target) =>
        Logger\debug "Stopping removal timer for: #{target}"

        timer.Remove @_timerName(target)

    _sendPrompt: (target) =>
        Logger\debug "Sending prompt for: #{target}"

        { :attempts, :token, :lifetime } = @sessions[target\SteamID64!]

        net.Start @promptMessage
        net.WriteString token
        net.WriteUInt lifetime, 8
        net.WriteUInt @maxAttempts, 3
        net.WriteUInt attempts, 3
        net.Send target

    _verifySession: (target) =>
        Logger\debug "Verifying session for: #{target}"

        -- Does a session exist
        target = target\SteamID64!
        session = @sessions[target]

        return true if session

        ErrorNoHaltWithStack "No session for given target: #{target}"

        false

    _verifyLifetime: (target) =>
        Logger\debug "Verifying lifetime for: #{target}"

        targetSteamID = target\SteamID64!
        session = @sessions[targetSteamID]
        sessionExpiration = session.sent + session.lifetime

        return true if os.time! < sessionExpiration

        Logger\warn "Session expired for #{targetSteamID}"
        @remove target

        false

    _verifyAttempts: (target) =>
        Logger\debug "Verifying attempts for: #{target}"

        targetSteamID = target\SteamID64!
        session = @sessions[targetSteamID]

        return true if session.attempts <= @maxAttempts

        false

    -- If the token is wrong, something is sus
    -- TODO: Webhook if incorrect token
    _verifyToken: (target) =>
        givenToken = net.ReadString!
        Logger\debug "Verifying token for: #{target}, '#{givenToken}'"

        target = target\SteamID64!
        expected = @sessions[target].token

        return true if givenToken == expected

        ErrorNoHaltWithStack "Invalid token given! Expected '#{expected}'. Received: '#{givenToken}'"

        false

    start: (target) =>
        Logger\debug "Starting exchange session for: #{target}"

        return unless IsValid target
        targetSteamID = target\SteamID64!

        existing = @sessions[targetSteamID]
        attempts = existing and existing.attempts or -1
        attempts += 1

        token = @_generateToken!
        lifetime = @sessionLifetime
        sent = os.time!

        @sessions[targetSteamID] =
            :attempts
            :token
            :lifetime
            :sent

        @_sendPrompt target

    remove: (target) =>
        Logger\debug "Removing exchange session for: #{target}"

        @_stopRemovalTimer target
        @sessions[target\SteamID64!] = nil

    -- Acts as a verification layer
    -- Children should extend this method with business logic
    receiveResponse: (target) =>
        Logger\debug "Received exchange response for: #{target}"

        -- Verifying Sessions and Attempts protects against malicious action
        -- Shouldn't require any polish or interface with the user
        return false unless @_verifySession target
        @_stopRemovalTimer target

        if not @_verifyAttempts target
            @remove target
            @onFailure target, "Too many failed attempts!"
            error "Too many failed attempts for #{target}!"

        return false unless @_verifyLifetime target
        return false unless @_verifyToken target

        true

    onSuccess: =>
        error "NotImplemented"

    onFailedAttempt: =>
        error "NotImplemented"

    onFailure: =>
        error "NotImplemented"

ExchangeManager
