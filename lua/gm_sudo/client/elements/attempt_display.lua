local Text
Text = draw.Text
local DrawRect, SetDrawColor
do
  local _obj_0 = surface
  DrawRect, SetDrawColor = _obj_0.DrawRect, _obj_0.SetDrawColor
end
local Colors = {
  white = Color(255, 255, 255, 255),
  gray = Color(50, 50, 50, 255),
  lightRed = Color(255, 50, 50, 255)
}
local AttemptDisplay = {
  Init = function(self) end,
  Setup = function(self, maxAttempts, attemptCount)
    self.maxAttempts = maxAttempts
    self.attemptCount = attemptCount
    self:Dock(RIGHT)
    self:DockMargin(0, 16, 0, 0)
    self:SetSize(416, 64)
    self.widthModifier = 28
  end,
  Paint = function(self, w, h)
    local textXPos = w - self.maxAttempts * self.widthModifier - 4
    Text({
      text = "Attempts: ",
      font = "GmodSudo_SudoStandardFont",
      pos = {
        textXPos,
        0
      },
      xalign = TEXT_ALIGN_RIGHT,
      yalign = TEXT_ALIGN_TOP,
      color = Colors.white
    })
    for attempt = 1, self.maxAttempts do
      local rectWidth = w - attempt * self.widthModifier
      SetDrawColor(Colors.gray)
      DrawRect(rectWidth, 0, 24, 24)
      if (self.maxAttempts - attempt) < self.attemptCount then
        SetDrawColor(Colors.lightRed)
        DrawRect(rectWidth + 4, 4, 16, 16)
      end
    end
  end
}
return vgui.Register("GmodSudo_AttemptDisplay", AttemptDisplay, "DPanel")
