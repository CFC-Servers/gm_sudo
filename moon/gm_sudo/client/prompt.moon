import CreateFont from surface

import Logger from Sudo

CreateFont "GmodSudo_SudoPasswordFont",
    font: "DermaLarge"
    size: 48

CreateFont "GmodSudo_SudoStandardFont",
    font: "DermaLarge"
    size: 24

include "elements/sudo_panel.lua"

lastRequest = os.time!
requestSudo = ->
    Logger\debug "Requesting Sudo access!"
    return if os.time! < lastRequest + 10

    net.Start "GmodSudo_RequestSignIn"
    net.SendToServer!

    lastRequest = os.time!

concommand.Add "sudo", requestSudo
