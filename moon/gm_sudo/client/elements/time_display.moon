import NoTexture, Text from draw
import ceil, cos, pi, sin from math
import DrawPoly, SetDrawColor from surface
import insert from table

drawCirclePoly = (x, y, r, startAng, endAng) ->
    poly = {{:x, :y}}

    for ang = startAng - 90, endAng - 90 do
        dx = x + cos( ang / 180 * pi ) * r
        dy = y + sin( ang / 180 * pi ) * r

        insert poly, {x: dx, y: dy}

    DrawPoly poly

Colors =
    circleColor: Color 36, 41, 67, 255
    white: Color 255, 255, 255, 255

TimeDisplay =
    Setup: (lifetime) =>
        @lifetime = lifetime
        @startTime = RealTime!

        @Dock LEFT
        @DockMargin 0, 16, 0, 0
        @SetSize 64, 64

    Paint: (w, h) =>
        NoTexture!

        timeDiff = RealTime! - @startTime
        timeLeft = @lifetime - timeDiff

        -- TODO: Send alert that the prompt timed out
        parent\Close! unless timeLeft > 0

        circleAngle = timeLeft / @lifetime * 360
        circleColor = HSVToColor timeLeft / @lifetime * 120, 0.75, 1

        SetDrawColor circleColor
        drawCirclePoly w / 2, h / 2, 32, 0, circleAngle

        SetDrawColor Colors.circleColor
        drawCirclePoly w / 2, h / 2, 26, 0, 360

        Text
            text: tostring ceil timeLeft
            font: "GmodSudo_SudoStandardFont"
            pos: {w / 2, h / 2}
            xalign: TEXT_ALIGN_CENTER
            yalign: TEXT_ALIGN_CENTER
            color: Colors.white

vgui.Register "GmodSudo_TimeDisplay", TimeDisplay, "DPanel"
