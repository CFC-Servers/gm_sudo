local RoundedBox
RoundedBox = draw.RoundedBox
include("status_panel.lua")
include("attempt_display.lua")
include("password_input.lua")
include("time_display.lua")
local Colors = {
  cfcPrimary = Color(36, 41, 67, 255)
}
local NetMessages = include("gm_sudo/shared/net_messages.lua")
local ExchangePanel
local StatusPanel
local SudoPasswordPanel = {
  Init = function(self) end,
  Setup = function(self, token, lifetime, maxAttempts, attemptCount, responseMessage, showLifetime, showAttempts)
    if showLifetime == nil then
      showLifetime = true
    end
    if showAttempts == nil then
      showAttempts = true
    end
    self.token, self.lifetime, self.maxAttempts, self.attemptCount, self.responseMessage, self.showLifetime, self.showAttempts = token, lifetime, maxAttempts, attemptCount, responseMessage, showLifetime, showAttempts
    local w, h = 512, 192
    local xPos = ScrW() - w - 32
    local yPos = ScrH() - h - 32
    self:SetTitle("")
    self:SetPos(xPos, yPos)
    self:SetSize(w, h)
    self:SetDraggable(false)
    self:DockPadding(16, 16, 16, 16)
    self:ShowCloseButton(true)
    self:MakePopup()
    do
      local _with_0 = vgui.Create("DLabel", self)
      _with_0:Dock(TOP)
      _with_0:SetText("Enter password for sudo access: ")
      _with_0:SetFont("GmodSudo_SudoStandardFont")
    end
    self.input = vgui.Create("GmodSudo_PasswordInput", self)
    timer.Simple(0.1, function()
      return self.input:RequestFocus()
    end)
    if self.showLifetime then
      do
        local _with_0 = vgui.Create("GmodSudo_TimeDisplay", self)
        self.timeDisplay = _with_0
        _with_0:Setup(self.lifetime)
      end
    end
    if self.showAttempts then
      do
        local _with_0 = vgui.Create("GmodSudo_AttemptDisplay", self)
        self.attemptDisplay = _with_0
        _with_0:Setup(self.maxAttempts, self.attemptCount)
        return _with_0
      end
    end
  end,
  Paint = function(self, w, h)
    return RoundedBox(8, 0, 0, w, h, Colors.cfcPrimary)
  end,
  OnSubmit = function(self, password)
    local isValid = password ~= ""
    if isValid then
      net.Start(self.responseMessage)
      net.WriteString(self.token)
      net.WriteString(password)
      net.SendToServer()
      self:Remove()
      StatusPanel = vgui.Create("GmodSudo_StatusPanel")
      StatusPanel:SetLoading()
      return 
    end
  end
}
vgui.Register("GmodSudo_PasswordPanel", SudoPasswordPanel, "DFrame")
local newExchange
newExchange = function(message, bellsAndWhistles)
  if bellsAndWhistles == nil then
    bellsAndWhistles = true
  end
  return net.Receive(message, function()
    if ExchangePanel then
      ExchangePanel:Remove()
    end
    if StatusPanel then
      StatusPanel:Remove()
    end
    local token = net.ReadString()
    local lifetime = net.ReadUInt(8)
    local maxAttempts = net.ReadUInt(3)
    local attemptCount = net.ReadUInt(3)
    ExchangePanel = vgui.Create("GmodSudo_PasswordPanel")
    return ExchangePanel:Setup(token, lifetime, maxAttempts, attemptCount, message, bellsAndWhistles, bellsAndWhistles)
  end)
end
local closePanels
closePanels = function()
  if ExchangePanel then
    ExchangePanel:Remove()
  end
  if StatusPanel then
    return StatusPanel:Remove()
  end
end
newExchange(NetMessages.signInRequest)
net.Receive(NetMessages.signInSuccess, function()
  closePanels()
  StatusPanel = vgui.Create("GmodSudo_StatusPanel")
  return StatusPanel:SetSuccess()
end)
net.Receive(NetMessages.signInFailure, function()
  closePanels()
  local message = net.ReadString()
  return LocalPlayer():ChatPrint(message)
end)
newExchange(NetMessages.signUpRequest, false)
net.Receive(NetMessages.signUpSuccess, function()
  closePanels()
  StatusPanel = vgui.Create("GmodSudo_StatusPanel")
  return StatusPanel:SetSuccess()
end)
return net.Receive(NetMessages.signUpFailure, function()
  return closePanels()
end)
