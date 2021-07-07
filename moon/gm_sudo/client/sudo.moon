NetMessages = include "gm_sudo/shared/net_messages.lua"
Manager = include "gm_sudo/shared/sudo_manager.lua"

net.Receive NetMessages.addSudoPlayer, ->
    target = net.ReadEntity!
    Manager\add target
