import Text from draw
import DrawRect, SetDrawColor from surface

import Logger from Sudo

Colors =
    white: Color 255, 255, 255, 255
    gray: Color 50, 50, 50, 255
    lightRed: Color 255, 50, 50, 255

AttemptDisplay =
    Init: => -- no-op

    Setup: (maxAttempts, attemptCount)=>
        Logger\debug "Running AttemptDisplay Setup: #{maxAttempts}, #{attemptCount}"

        @maxAttempts = maxAttempts
        @attemptCount = attemptCount

        @Dock RIGHT
        @DockMargin 0, 16, 0, 0
        @SetSize 416, 64
        @widthModifier = 28

    Paint: (w, h) =>
        textXPos = w - @attemptCount * @widthModifier - 4

        Text
            text: "Attempts: "
            font: "CFC_SudoStandardFont"
            pos: {textXPos, 0}
            xalign: TEXT_ALIGN_RIGHT
            yalign: TEXT_ALIGN_TOP
            color: Colors.white

        for attempt = 1, @maxAttempts do
            rectWidth = w - attempt * @widthModifier

            SetDrawColor Colors.gray
            DrawRect rectWidth, 0, 24, 24

            if (@maxAttempts - attempt) < @attemptCount then
                SetDrawColor Colors.lightRed
                DrawRect rectWidth + 4, 4, 16, 16

vgui.Register "GmodSudo_AttemptDisplay", AttemptDisplay, "DPanel"
