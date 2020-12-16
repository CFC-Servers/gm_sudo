import CreateFont from surface

CreateFont "GmodSudo_SudoPasswordFont",
    font: "DermaLarge"
    size: 48

CreateFont "GmodSudo_SudoStandardFont",
    font: "DermaLarge"
    size: 24

include "elements/sudo_panel.lua"


requestSudo = ->
    net.Start "GmodSudo_RequestSignIn"
    net.SendToServer!

concommand.Add "sudo", requestSudo
