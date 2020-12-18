class SudoManager
    new: (@duration=30*60)=>
        @sessions = {}
        @wrapped = false

    _wrapSuperadmin: =>
        playerMeta = FindMetaTable "Player"
        originalIsSuper = playerMeta.IsSuperAdmin

        playerMeta.IsSuperAdmin = (ply) ->
            unless expiration = @sessions[ply]
                return originalIsSuper ply

            return true unless os.time! >= expiration

            @sessions[ply] = nil
            originalIsSuper ply

        @wrapped = true

    add: (ply) =>
        @_wrapSuperadmin! unless @wrapped
        @sessions[ply] = os.time! + @duration

SudoManager!
