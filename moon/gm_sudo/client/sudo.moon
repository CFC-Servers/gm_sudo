Manager = include "gm_sudo/sudo_manager.lua"

net.Receive "GmodSudo_AddSudoPlayer", ->
    target = net.ReadEntity!
    Manager\add target
