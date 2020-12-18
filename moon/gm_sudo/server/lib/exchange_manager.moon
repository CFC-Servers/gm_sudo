require "securerandom"
import Base64Encode from util

import Logger from Sudo

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

    _generateToken: => Base64Encode random.Bytes @tokenSize

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
        error "No session for given target: #{target}" unless session

    _verifyLifetime: (target) =>
        Logger\debug "Verifying lifetime for: #{target}"

        target = target\SteamID64!
        session = @sessions[target]

        sessionExpiration = session.sent + session.lifetime
        if os.time! > sessionExpiration
            Logger\debug "Session expired for #{target}"
            @sessions[target] = nil
            return false

    _verifyAttempts: (target) =>
        Logger\debug "Verifying attempts for: #{target}"

        target = target\SteamID64!
        session = @sessions[target]

        if session.attempts >= @maxAttempts
            @sessions[target] = nil
            error "Ran out of attempts! Person: #{target}"

    -- If the token is wrong, something is sus
    _verifyToken: (target) =>
        Logger\debug "Verifying token for: #{target}, '#{givenToken}'"

        target = target\SteamID64!
        expected = @sessions[target].token

        if net.ReadString! ~= expected
            error "Invalid token given! Expected '#{expected}'. Received: '#{givenToken}'"

    start: (initiator, target) =>
        Logger\debug "Starting exchange session for: #{target}"

        return unless IsValid target
        targetSteamId = target\SteamID64!

        existing = @sessions[targetSteamId]
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

        @_sendPrompt target

    remove: (target) =>
        Logger\debug "Removing exchange session for: #{target}"

        @sessions[target] = nil

    -- Acts as a verification layer
    -- Children should extend this method with business logic
    receiveResponse: (target) =>
        Logger\debug "Received exchange response for: #{target}"

        -- Verifying Sessions and Attempts protects against malicious action
        -- Shouldn't require any polish or interface with the user
        -- These are designed to raise an error if something goes wrong
        @_verifySession target
        @_stopRemovalTimer target
        @_verifyAttempts target

        return false unless @_verifyLifetime(target) == nil

        @_verifyToken target

        true

    onSuccess: =>
        error "NotImplemented"

    onFailedAttempt: =>
        error "NotImplemented"

    onFailure: =>
        error "NotImplemented"

ExchangeManager
