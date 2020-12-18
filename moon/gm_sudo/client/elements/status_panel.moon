import RoundedBox from draw
import PlaySound from surface

import Logger from Sudo

Colors =
    cfcPrimary: Color 36, 41, 67, 255

StatusPanel =
    Init: =>
        Logger\debug "Running Init for StatusPanel"

        w, h = 512, 192

        xPos = ScrW! - w - 32
        yPos = ScrH! - h - 32

        @SetTitle ""
        @SetPos xPos, yPos
        @SetSize w, h
        @SetDraggable false
        @DockPadding 16, 16, 16, 16
        @ShowCloseButton true

        @label = nil

    Paint: (w, h) =>
        RoundedBox 8, 0, 0, w, h, Colors.cfcPrimary

    Clear: =>
        @label\Remove! if @label
        @loading\Remove! if @loading
        @success\Remove! if @success
        @failure\Remove! if @failure

    SetLoading: =>
        @Clear!

        @label = with vgui.Create "DLabel", self
            \Dock TOP
            \SetText "Waiting for a response..."
            \SetFont "GmodSudo_SudoStandardFont"

        @success = with vgui.Create "DImage", self
            \SetImage "gm_sudo/hourglass.png"
            \SetSize 100, 100
            \Center!

    SetSuccess: =>
        @Clear!

        animationTime = 3.5

        @success = with vgui.Create "DImage", self
            \SetImage "gm_sudo/success.png"
            \SetSize 150, 136
            \Center!
            \SetAlpha 0
            \AlphaTo 255, animationTime * 0.66, 0, -> PlaySound "gm_sudo/access_granted.mp3"

        timer.Create "GmodSudo_SuccessDestroyTimer", animationTime, 1, ->
            @AlphaTo 0, 0.5, 0, -> @Remove!

vgui.Register "GmodSudo_StatusPanel", StatusPanel, "DFrame"
