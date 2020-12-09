util.AddNetworkString "GmodSudo_RequestSignIn"

class SudoManager
    new: (ply, duration=30*60) =>
        @ply = ply
        @duration = duration
        @wrapSuperadmin!

    wrapSuperadmin: =>
        expiration = os.time! + @duration
        @originalSuperadmin = ply.IsSuperAdmin

        ply.IsSuperAdmin = ->
            now = os.time!
            return true unless now >= expiration

            ply.IsSuperAdmin = @originalSuperadmin
            return @originalSuperadmin @ply

Sudo =
    SignUpManager: require "signup.lua"
    SignInManager:  require "signin.lua"

Sudo.SignInManager.onSuccess = (target) =>
    SudoManager target

net.Receive "GmodSudo_RequestSignIn", (_, ply) ->
    Sudo.SignUpManager\start ply, ply
