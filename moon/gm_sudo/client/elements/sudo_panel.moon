import RoundedBox from draw

include "status_panel.lua"
include "attempt_display.lua"
include "password_input.lua"
include "time_display.lua"

Colors =
    cfcPrimary: Color 36, 41, 67, 255

NetMessages = include "gm_sudo/shared/net_messages.lua"

local ExchangePanel
local StatusPanel

SudoPasswordPanel =
    Setup: (@token, @lifetime, @maxAttempts, @attemptCount, @responseMessage, @showLifetime=true, @showAttempts=true) =>
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
        timer.Simple 0.1, -> @input\RequestFocus!

        if @showLifetime
            with @timeDisplay = vgui.Create "GmodSudo_TimeDisplay", self
                \Setup @lifetime

        if @showAttempts
            with @attemptDisplay = vgui.Create "GmodSudo_AttemptDisplay", self
                \Setup @maxAttempts, @attemptCount

    Paint: (w, h) =>
        RoundedBox 8, 0, 0, w, h, Colors.cfcPrimary

    OnSubmit: (password) =>
        isValid = password ~= ""

        -- TODO: Clientside validation

        if isValid
            net.Start @responseMessage
            net.WriteString @token
            net.WriteString password
            net.SendToServer!

            self\Remove!
            StatusPanel = vgui.Create "GmodSudo_StatusPanel"
            StatusPanel\SetLoading!

            return

        -- TODO: Handle invalid input

vgui.Register "GmodSudo_PasswordPanel", SudoPasswordPanel, "DFrame"

newExchange = (message, bellsAndWhistles=true) ->
    net.Receive message, ->
        ExchangePanel\Remove! if ExchangePanel
        StatusPanel\Remove! if StatusPanel

        token = net.ReadString!
        lifetime = net.ReadUInt 8
        maxAttempts = net.ReadUInt 3
        attemptCount = net.ReadUInt 3

        ExchangePanel = vgui.Create "GmodSudo_PasswordPanel"
        ExchangePanel\Setup token, lifetime, maxAttempts, attemptCount, message, bellsAndWhistles, bellsAndWhistles


closePanels = ->
    ExchangePanel\Remove! if ExchangePanel
    StatusPanel\Remove! if StatusPanel

-- SignIn

newExchange NetMessages.signInRequest

net.Receive NetMessages.signInSuccess, ->
    closePanels!

    StatusPanel = vgui.Create "GmodSudo_StatusPanel"
    StatusPanel\SetSuccess!

net.Receive NetMessages.signInFailure, ->
    closePanels!
    message = net.ReadString!

    LocalPlayer!\ChatPrint message

-- SignUp

newExchange NetMessages.signUpRequest, false

net.Receive NetMessages.signUpSuccess, ->
    closePanels!

    StatusPanel = vgui.Create "GmodSudo_StatusPanel"
    StatusPanel\SetSuccess!

net.Receive NetMessages.signUpFailure, ->
    closePanels!
