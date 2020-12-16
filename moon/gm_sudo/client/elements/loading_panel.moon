import RoundedBox from draw

import Logger from Sudo

Colors =
    cfcPrimary: Color 36, 41, 67, 255

-- TODO: Make this a loading screen
LoadingPanel =
    Init: =>
        Logger\debug "Running Init for LoadingPanel"

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
            \SetText "Waiting for a response..."
            \SetFont "GmodSudo_SudoStandardFont"

    Paint: (w, h) =>
        RoundedBox 8, 0, 0, w, h, Colors.cfcPrimary

vgui.Register "GmodSudo_LoadingPanel", LoadingPanel, "DFrame"
