class SudoManager
    new: (@duration=30*60)=>
        @sessions = {}
        @wrapped = false

    _wrapSuperadmin: =>
        playerMeta = FindMetaTable "Player"
        originalIsSuper = playerMeta.IsSuperAdmin

        playerMeta.IsSuperAdmin = (ply) ->
            steamId = ply\SteamID64!
            expiration = @sessions[steamId]

            return originalIsSuper ply unless expiration
            return true unless os.time! >= expiration

            @sessions[steamId] = nil
            originalIsSuper ply

        @wrapped = true

    add: (ply) =>
        @_wrapSuperadmin! unless @wrapped
        @sessions[ply] = os.time! + @duration

SudoManager!
