import CreateFont from surface

import Logger from Sudo

CreateFont "GmodSudo_SudoPasswordFont",
    font: "DermaLarge"
    size: 48

CreateFont "GmodSudo_SudoStandardFont",
    font: "DermaLarge"
    size: 24

include "elements/sudo_panel.lua"

requestSudo = ->
    Logger\debug "Requesting Sudo access!"

    net.Start "GmodSudo_RequestSignIn"
    net.SendToServer!

concommand.Add "sudo", requestSudo
