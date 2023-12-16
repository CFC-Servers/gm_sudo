local RoundedBox, Text
do
  local _obj_0 = draw
  RoundedBox, Text = _obj_0.RoundedBox, _obj_0.Text
end
local min
min = math.min
local len, rep
do
  local _obj_0 = string
  len, rep = _obj_0.len, _obj_0.rep
end
local Colors = {
  white = Color(255, 255, 255, 255)
}
local PasswordInput = {
  Init = function(self)
    self:Dock(TOP)
    self:DockMargin(0, 16, 0, 0)
    self:DockPadding(5, 2, 5, 2)
    self:SetSize(480, 32)
    self:SetMultiline(true)
    self:SetEnterAllowed(false)
    self.lastAttempt = RealTime()
  end,
  Paint = function(self, w, h)
    local timeDiff = min(RealTime() - self.lastAttempt, 2)
    local attemptColor = 150 - timeDiff * 75
    local inputColor = Color(42 + attemptColor, 47, 74, 255)
    RoundedBox(4, 0, 0, w, h, inputColor)
    local textLength = len(self:GetValue())
    return Text({
      text = rep("·", textLength),
      font = "GmodSudo_SudoPasswordFont",
      pos = {
        0,
        0
      },
      color = Colors.white
    })
  end,
  AllowInput = function(self, char)
    if not (char == "\n") then
      return 
    end
    self:OnEnter(self:GetValue())
    return true
  end,
  OnEnter = function(self, str)
    return self:GetParent():OnSubmit(str)
  end
}
return vgui.Register("GmodSudo_PasswordInput", PasswordInput, "DTextEntry")
