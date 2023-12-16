local NoTexture, Text
do
  local _obj_0 = draw
  NoTexture, Text = _obj_0.NoTexture, _obj_0.Text
end
local ceil, cos, pi, sin
do
  local _obj_0 = math
  ceil, cos, pi, sin = _obj_0.ceil, _obj_0.cos, _obj_0.pi, _obj_0.sin
end
local DrawPoly, SetDrawColor
do
  local _obj_0 = surface
  DrawPoly, SetDrawColor = _obj_0.DrawPoly, _obj_0.SetDrawColor
end
local insert
insert = table.insert
local drawCirclePoly
drawCirclePoly = function(x, y, r, startAng, endAng)
  local poly = {
    {
      x = x,
      y = y
    }
  }
  for ang = startAng - 90, endAng - 90 do
    local dx = x + cos(ang / 180 * pi) * r
    local dy = y + sin(ang / 180 * pi) * r
    insert(poly, {
      x = dx,
      y = dy
    })
  end
  return DrawPoly(poly)
end
local Colors = {
  circleColor = Color(36, 41, 67, 255),
  white = Color(255, 255, 255, 255)
}
local TimeDisplay = {
  Init = function(self) end,
  Setup = function(self, lifetime)
    self.lifetime = lifetime
    self.startTime = RealTime()
    self:Dock(LEFT)
    self:DockMargin(0, 16, 0, 0)
    return self:SetSize(64, 64)
  end,
  Paint = function(self, w, h)
    NoTexture()
    local timeDiff = RealTime() - self.startTime
    local timeLeft = self.lifetime - timeDiff
    if not (timeLeft > 0) then
      parent:Close()
    end
    local circleAngle = timeLeft / self.lifetime * 360
    local circleColor = HSVToColor(timeLeft / self.lifetime * 120, 0.75, 1)
    SetDrawColor(circleColor)
    drawCirclePoly(w / 2, h / 2, 32, 0, circleAngle)
    SetDrawColor(Colors.circleColor)
    drawCirclePoly(w / 2, h / 2, 26, 0, 360)
    return Text({
      text = tostring(ceil(timeLeft)),
      font = "GmodSudo_SudoStandardFont",
      pos = {
        w / 2,
        h / 2
      },
      xalign = TEXT_ALIGN_CENTER,
      yalign = TEXT_ALIGN_CENTER,
      color = Colors.white
    })
  end
}
return vgui.Register("GmodSudo_TimeDisplay", TimeDisplay, "DPanel")
