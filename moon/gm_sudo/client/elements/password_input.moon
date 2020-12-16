import RoundedBox, Text from draw
import min from math
import len, rep from string

import Logger from Sudo

Colors =
    white: Color 255, 255, 255, 255

PasswordInput =
    Init: =>
        Logger\debug "Running Init in PasswordInput"

        @Dock TOP
        @DockMargin 0, 16, 0, 0
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
            text: rep "*", textLength
            font: "GmodSudo_SudoPasswordFont"
            pos: {0, 0}
            color: Colors.white

    AllowInput: (char) =>
        Logger\debug "Running AllowInput in PasswordInput"

        return unless char == "\n"

        @OnEnter @GetValue!
        return true

    OnEnter: (str) =>
        Logger\debug "Running OnEnter in PasswordInput"

        @GetParent!\OnSubmit str

vgui.Register "GmodSudo_PasswordInput", PasswordInput, "DTextEntry"
