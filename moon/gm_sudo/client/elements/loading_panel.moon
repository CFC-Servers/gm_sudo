import RoundedBox from draw

Colors =
    cfcPrimary: Color 36, 41, 67, 255

LoadingPanel =
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

    Paint: (w, h) =>
        RoundedBox 8, 0, 0, w, h, Colors.cfcPrimary

vgui.Register "GmodSudo_LoadingPanel", LoadingPanel, "DFrame"
