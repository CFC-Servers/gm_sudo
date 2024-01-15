duration = CreateConVar "gm_sudo_session_length", 30*60, FCVAR_REPLICATED, "How many seconds should each Sudo session last", 0

class SudoManager
    new: =>
        @sessions = {}
        @ready = false
        @duration = duration\GetInt!

    _wrap: (func, returnValue=true) =>
        playerMeta = FindMetaTable "Player"
        original = playerMeta[func]

        playerMeta[func] = (ply) ->
            steamId = ply\SteamID64!
            expiration = @sessions[steamId]

            return original(ply) unless expiration
            return returnValue unless os.time! >= expiration

            @sessions[steamId] = nil
            original(ply)

    _setup: =>
        @_wrap "IsAdmin"
        @_wrap "IsSuperAdmin"

        --@_wrap "CheckGroup"
        @_wrap "GetUserGroup", "superadmin" if SERVER

        hook.Add "CAMI.PlayerHasAccess", "GmodSudo_CAMI", (ply, privilege, callback) ->
            return unless @sessions[ply\SteamID64!]
            callback true
            return true

        hook.Add "CAMI.SteamIDHasAccess", "GmodSudo_CAMI", (steamID, privilege, callback) ->
            return unless @sessions[util.SteamIDTo64 steamID]
            callback true
            return true

        @ready = true

    add: (ply) =>
        @_setup! unless @ready
        @sessions[ply\SteamID64!] = os.time! + @duration

SudoManager!
