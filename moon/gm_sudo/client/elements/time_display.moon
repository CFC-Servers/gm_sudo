import NoTexture from draw
import ceil, cos, pi, sin from math
import SetDrawColor from surface

drawCirclePoly = (x, y, r, startAng, endAng) ->
    poly = {{:x, :y}}

    for ang = startAng - 90, endAng - 90 do
        dx = x + cos( ang / 180 * pi ) * r
        dy = y + sin( ang / 180 * pi ) * r

        insert poly, {x: dx, y: dy}

TimeDisplay =
    Init: =>
        @Dock LEFT
        @DockMargin 0, 16, 0, 0
        @SetSize 64, 64

    Paint: (w, h) =>
        NoTexture!

        parent = @GetParent!
        promptTime = parent.promptTime
        timeDiff = RealTime! - parent.startTime
        timeLeft = promptTime - timeDiff

        parent\Close! unless timeLeft > 0

        circleAngle = timeLeft / promptTime * 360
        circleColor = HSVToColor timeLeft / promptTime * 120, 0.75, 1

        SetDrawColor circleColor
        drawCirclePoly w / 2, h / 2, 32, 0, circleAngle

        SetDrawColor Color 36, 41, 67, 255
        drawCirclePoly w / 2, h / 2, 26, 0, 360

        Text
            text: tostring ceil timeLeft
            font: "CFC_SudoStandardFont"
            pos: {w / 2, h / 2}
            xalign: TEXT_ALIGN_CENTER
            yalign: TEXT_ALIGN_CENTER
            color: Color 255, 255, 255, 255

vgui.Register "GmodSudo_TimeDisplay", TimeDisplay, "DPanel"
