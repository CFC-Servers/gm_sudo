import RoundedBox from draw

import Logger from Sudo

include "loading_panel.lua"
include "attempt_display.lua"
include "password_input.lua"
include "time_display.lua"

Colors =
    cfcPrimary: Color 36, 41, 67, 255

local ExchangePanel
local LoadingPanel

SudoPasswordPanel =
    Init: => -- no-op

    Setup: (@token, @lifetime, @maxAttempts, @attemptCount, @responseMessage, @showLifetime=true, @showAttempts=true) =>
        Logger\debug "Running Setup in SudoPasswordPanel: #{token}, #{lifetime}, #{maxAttempts}, #{attemptCount}, #{responseMessage}, #{showLifetime}, #{showAttempts}"

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

        if @showLifetime
            with @timeDisplay = vgui.Create "GmodSudo_TimeDisplay", self
                \Setup @lifetime

        if @showAttempts
            with @attemptDisplay = vgui.Create "GmodSudo_AttemptDisplay", self
                \Setup @maxAttempts, @attemptCount

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

vgui.Register "GmodSudo_PasswordPanel", SudoPasswordPanel, "DFrame"

newExchange = (message, bellsAndWhistles=true) ->
    net.Receive message, ->
        Logger\debug "Received '#{message}' request, clearing panels and reading data"

        ExchangePanel\Remove! if ExchangePanel
        LoadingPanel\Remove! if LoadingPanel

        token = net.ReadString!
        lifetime = net.ReadUInt 8
        maxAttempts = net.ReadUInt 3
        attemptCount = net.ReadUInt 3

        Logger\debug "#{message} request data: #{token}, #{lifetime}, #{maxAttempts}, #{attemptCount}"

        ExchangePanel = vgui.Create "GmodSudo_PasswordPanel"
        ExchangePanel\Setup token, lifetime, maxAttempts, attemptCount, message, bellsAndWhistles, bellsAndWhistles

newExchange "GmodSudo_SignIn"
newExchange "GmodSudo_SignUp", false
