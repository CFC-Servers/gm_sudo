import RoundedBox from draw

import Logger from Sudo

include "loading_panel.lua"
include "attempt_display.lua"
include "password_input.lua"
include "time_display.lua"

Colors =
    cfcPrimary: Color 36, 41, 67, 255

local PasswordPanel
local LoadingPanel

SudoPasswordPanel =
    Init: => -- no-op

    Setup: (token, lifetime, maxAttempts, attemptCount, responseMessage) =>
        Logger\debug "Running Setup in SudoPasswordPanel: #{token}, #{lifetime}, #{maxAttempts}, #{attemptCount}, #{responseMessage}"

        @token = token
        @lifetime = lifetime
        @maxAttempts = maxAttempts
        @attemptCount = attemptCount
        @responseMessage = responseMessage

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
            \SetFont "GmodSudo_SudoStandardFont"

        @input = vgui.Create "GmodSudo_PasswordInput", self

        @timeDisplay = vgui.Create "GmodSudo_TimeDisplay", self
        @timeDisplay\Setup @lifetime

        @attemptDisplay = vgui.Create "GmodSudo_AttemptDisplay", self
        @attemptDisplay\Setup @maxAttempts, @attemptCount

    Paint: (w, h) =>
        RoundedBox 8, 0, 0, w, h, Colors.cfcPrimary

    OnSubmit: (password) =>
        Logger\debug "Running OnSubmit in SudoPasswordPanel"

        isValid = password ~= ""

        -- TODO: Clientside validation

        if isValid
            net.Start @responseMessage
            net.WriteString @token
            net.WriteString password
            net.SendToServer!

            self\Remove!
            LoadingPanel = vgui.Create "GmodSudo_LoadingPanel"

            return

        -- TODO: Handle invalid input

net.Receive "GmodSudo_SignIn", ->
    Logger\debug "Received SignIn request, clearing panels and reading data"

    if PasswordPanel
        PasswordPanel\Remove!

    if LoadingPanel
        LoadingPanel\Remove!

    token = net.ReadString!
    lifetime = net.ReadUInt 8
    maxAttempts = net.ReadUInt 3
    attemptCount = net.ReadUInt 3

    Logger\debug "SignIn request data: #{token}, #{lifetime}, #{maxAttempts}, #{attemptCount}"

    PasswordPanel = vgui.Create "GmodSudo_PasswordPanel"
    PasswordPanel\Setup token, lifetime, maxAttempts, attemptCount, "GmodSudo_SignIn"

vgui.Register "GmodSudo_PasswordPanel", SudoPasswordPanel, "DFrame"
