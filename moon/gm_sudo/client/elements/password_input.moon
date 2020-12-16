import RoundedBox, Text from draw
import min from math
import len, rep from string

Colors =
    white: Color 255, 255, 255, 255

PasswordInput =
    Init: =>
        @Dock TOP
        @DockMargin 0, 16, 0, 0
        @SetSize 480, 32
        @SetMultiline true
        @SetEnterAllowed false
        @lastAttempt = 0

    Paint: (w, h) =>
        timeDiff = min RealTime! - @lastAttempt, 2
        attemptColor = 150 - timeDiff * 75
        inputColor = Color 42 + attemptColor, 47, 74, 255

        RoundedBox 4, 0, 0, w, h, inputColor

        textLength = len @GetValue!

        Text
            text: rep "*", textLength
            font: "GmodSudo_SudoPasswordFont"
            pos: {0, 0}
            color: Colors.white

    AllowInput: (char) =>
        return false if char == "\n"

        @OnEnter @GetValue!

        true

    OnEnter: (str) =>
        -- TODO: Validation here
        isValid = str == "Cheese"

        if isValid
            -- TODO: Send request

            return @GetParent!\Close!

        @lastAttempt = RealTime!

        parent = @GetParent!
        return unless parent.failedAttempts

        parent.failedAttempts += 1

        return parent\Close! if parent.failedAttempts == parent.attempts

vgui.Register "GmodSudo_PasswordInput", PasswordInput, "DTextEntry"
