class SudoManager
    new: (@duration=30*60)=>
        @sessions = {}
        @wrapped = false

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

    _wrapFunctions: =>
        @_wrap "IsAdmin"
        @_wrap "IsSuperAdmin"

        @_wrap "CheckGroup"
        @_wrap "GetUserGroup", "superadmin" if SERVER

        @wrapped = true

    add: (ply) =>
        @_wrapFunctions! unless @wrapped
        @sessions[ply\SteamID64!] = os.time! + @duration

SudoManager!
