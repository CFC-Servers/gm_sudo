import Text from draw
import DrawRect, SetDrawColor from surface

Colors =
    white: Color 255, 255, 255, 255
    gray: Color 50, 50, 50, 255
    lightRed: Color 255, 50, 50, 255

AttemptDisplay =
    Init: =>
        @Dock RIGHT
        @DockMargin 0, 16, 0, 0
        @SetSize 416, 64
        @widthModifier = 28

    Paint: (w, h) =>
        attempts = @GetParent!.attempts
        textXPos = w - attempts * @widthModifier - 4

        Text
            text: "Attempts: "
            font: "CFC_SudoStandardFont"
            pos: {textXPos, 0}
            xalign: TEXT_ALIGN_RIGHT
            yalign: TEXT_ALIGN_TOP
            color: Colors.white

        for attempt = 1, attempts do
            rectWidth = w - attempt * @widthModifier

            SetDrawColor Colors.gray
            DrawRect rectWidth, 0, 24, 24

            if (attempts - attempt) < @GetParent!.failedAttempts then
                SetDrawColor Colors.lightRed
                DrawRect rectWidth + 4, 4, 16, 16

vgui.Register "GmodSudo_AttemptDisplay", AttemptDisplay, "DPanel"
