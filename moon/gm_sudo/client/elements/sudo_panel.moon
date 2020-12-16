import RoundedBox from draw

include "attempt_display.lua"
include "password_input.lua"
include "time_display.lua"

Colors =
    cfcPrimary: Color 36, 41, 67, 255

SudoPasswordPanel =
    Init: =>
        w, h = 512, 192

        xPos = ScrW! - w - 32
        yPos = ScrH! - h - 32

        @SetTitle ""
        @SetPos xPos, yPos
        @SetSize w, h
        @SetDraggable false
        @DockPadding 16, 16, 16, 16
        @ShowCloseButton true
        @MakePopup!

        with vgui.Create "DLabel", self
            \Dock TOP
            \SetText "Enter password for sudo access: "
            \SetFont "GmodSudo_SudoStandardFont"

        vgui.Create "GmodSudo_PasswordInput", self

    SetPromptTime: (promptTime) =>
        @startTime = RealTime!
        @promptTime = promptTime

        vgui.Create "GmodSudo_TimeDisplay", self

    SetAttemptCount: (attempts) =>
        @attempts = attempts
        @failedAttempts = 0

        vgui.Create "GmodSudo_AttemptDisplay", self

    Paint: (w, h) =>
        RoundedBox 8, 0, 0, w, h, Colors.cfcPrimary

vgui.Register "GmodSudo_PasswordPanel", SudoPasswordPanel, "DFrame"
