import CreateFont, DrawRect, RoundedBox, SetDrawColor from surface
import ceil, cos, min, pi, sin from math
import insert from table
import NoTexture, RoundedBox, Text from draw
import len from string

CreateFont "CFC_SudoPasswordFont",
    font: "DermaLarge"
    size: 48

CreateFont "CFC_SudoStandardFont",
    font: "DermaLarge"
    size: 24

drawCirclePoly = (x, y, r, startAng, endAng) ->
    poly = {{:x, :y}}

    for ang = startAng - 90, endAng - 90 do
        dx = x + cos( ang / 180 * pi ) * r
        dy = y + sin( ang / 180 * pi ) * r

        insert poly, {x: dx, y: dy}

PasswordInput = (parent) ->
    textInput = vgui.Create "DTextEntry", parent
    with textInput
        \Dock TOP
        \DockMargin 0, 16, 0, 0
        \SetSize 480, 32
        \SetMultiline true
        \SEtEnterAllowed false
        .lastAttempt = 0

    textInput.Paint = (w, h) =>
        attemptColor = 150 - min(RealTime! - @lastAttempt, 2) * 75
        inputColor = Color 42 + attemptColor, 47, 74, 255

        RoundedBox 4, 0, 0, w, h, inputColor

        textLength = len @GetValue!

        Text
            text: rep "*", textLength
            font: "CFC_SudoPasswordFont"
            pos: {0, 0}
            color: Color 255, 255, 255, 255

    textInput.AllowInput = (char) =>
        return false unless char == "\n"

        @OnEnter @GetValue!

        true

    textInput.OnEnter = (str) =>
        -- TODO: Validation here
        isValid = str == "Cheese"

        if isValid
            -- TODO: Send request

            return @GetParent!\Close!

        @lastAttempt = RealTime!

        parent = @GetParent!

        return unless parent.failedAttempts

        parent.failedAttempts += 1
        if parent.failedAttempts == parent.attempts
            parent\Close!

    return textInput

AttemptDisplay = (parent) ->
    attemptDisplay = vgui.Create "DPanel", parent
    with attemptDisplay
        \Dock RIGHT
        \DockMargin 0, 16, 0, 0
        \SetSize 416, 64

    attemptDisplay.Paint = (w, h) =>
        attempts = @GetParent!.attempts

        Text
            text: "Attempts: "
            font: "CFC_PasswordUI"
            pos: {w - attempts * 28 - 4, 0}
            xalign: TEXT_ALIGN_RIGHT
            yalign: TEXT_ALIGN_TOP
            color: Color 255, 255, 255, 255

        for attempt = 1, attempts do
            SetDrawColor Color 50, 50, 50, 255
            DrawRect w - attempt * 28, 0, 24, 24

            if (attempts - attemt) < @GetParent!.failedAttempts then
                SetDrawColor Color 255, 50, 50, 255
                DrawRect w - attempt * 28 + 4, 4, 16, 16

TimeDisplay = (parent) ->
    timeDisplay = vgui.Create "DPanel", parent
    with timeDisplay
        \Dock LEFT
        \DockMargin 0, 16, 0, 0
        \SetSize 64, 64

    timeDisplay.Paint = (w, h) =>
        NoTexture!

        parent = @GetParent!
        promptTime = parent.promptTime
        timeLeft = promptTime - ( RealTime! - parent.startTime)

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
            \SetFont "CFC_SudoStandardFont"

        PasswordInput self

    SetPromptTime: (promptTime) =>
        @startTime = RealTime!
        @promptTime = promptTime

        TimeDisplay self

    SetAttemptCount: (attempts) =>
        @attempts = attempts
        @failedAttempts = 0

        AttemptDisplay self

    Paint: (w, h) =>
        RoundedBox 8, 0, 0, w, h, Color 36, 41, 67, 255

vgui.Register "CFC_SudoPasswordPanel", SudoPasswordPanel, "DFrame"
