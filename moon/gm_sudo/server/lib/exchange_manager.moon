require "securerandom"
import Base64Encode from util

class ExchangeManager
    new: =>
        @sessions = {}
        @maxAttempts = 3
        @tokenSize = 16
        @sessionLifetime = 120
        @promptMessage = nil

    _createListener: =>
        net.Receive @promptMessage, (_, ply) ->
            @receiveResponse ply

    _timerName: (target) =>
        error "NotImplemented"

    _generateToken: => Base64Encode random.Bytes @tokenSize

    _createRemovalTimer: (target) =>
        timer.Create @_timerName(target), @sessionLifetime, 1, ->
            @remove target

    _stopRemovalTimer: (target) =>
        timer.Remove @_timerName(target)

    _sendPrompt: (target) =>
        { :attempts, :token, :lifetime } = @sessions[target\SteamID64!]

        net.Start @promptMessage
        net.WriteString token
        net.WriteUInt lifetime, 8
        net.WriteUInt attempts, 3
        net.Send target

    _verifySession: (target) =>
        -- Does a session exist
        target = target\SteamID64!
        session = @sessions[target]
        error "No session for given target: #{target}" unless session

    _verifyLifetime: (target) =>
        target = target\SteamID64!
        session = @sessions[target]

        sessionExpiration = session.sent + session.lifetime
        if os.time! > sessionExpiration
            -- TODO: Some alert here
            @start target
            return false

    _verifyAttempts: (target) =>
        target = target\SteamID64!
        session = @sessions[target]

        if session.attempts >= @maxAttempts
            error "Ran out of attempts! Person: #{target}"

    -- If the token is wrong, something is sus
    _verifyToken: (target, givenToken) =>
        target = target\SteamID64!
        expected = @sessions[target].token

        if givenToken ~= expected
            error "Invalid token given! Expected '#{expected}'. Received: '#{givenToken}'"

    start: (initiator, target) =>
        return unless IsValid target
        targetSteamId = target\SteamID64!

        existing = @session[targetSteamId]
        attempts = existing and existing.attempts or -1
        attempts += 1

        token = @_generateToken!
        lifetime = @sessionLifetime
        sent = os.time!

        @sessions[targetSteamId] =
            :initiator
            :attempts
            :token
            :lifetime
            :sent

    remove: (target) =>
        @sessions[target] = nil

    receiveResponse: (target) =>
        @_verifySession target
        @_stopRemovalTimer target
        @_verifyAttempts target

        return unless @_verifyLifetime(target) == nil

        givenToken = net.ReadString!
        @_verifyToken givenToken

ExchangeManager
