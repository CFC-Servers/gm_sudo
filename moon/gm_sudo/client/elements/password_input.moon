import RoundedBox, Text from draw
import min from math
import len, rep from string

Colors =
    white: Color 255, 255, 255, 255

PasswordInput =
    Init: =>
        @Dock TOP
        @DockMargin 0, 16, 0, 0
        @DockPadding 5, 2, 5, 2
        @SetSize 480, 32
        @SetMultiline true
        @SetEnterAllowed false
        @lastAttempt = RealTime!

    Paint: (w, h) =>
        timeDiff = min RealTime! - @lastAttempt, 2
        attemptColor = 150 - timeDiff * 75
        inputColor = Color 42 + attemptColor, 47, 74, 255

        RoundedBox 4, 0, 0, w, h, inputColor

        textLength = len @GetValue!

        Text
            text: rep "·", textLength
            font: "GmodSudo_SudoPasswordFont"
            pos: {0, 0}
            color: Colors.white

    AllowInput: (char) =>
        return unless char == "\n"

        @OnEnter @GetValue!
        return true

    OnEnter: (str) =>
        @GetParent!\OnSubmit str

vgui.Register "GmodSudo_PasswordInput", PasswordInput, "DTextEntry"
