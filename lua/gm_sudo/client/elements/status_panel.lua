local RoundedBox
RoundedBox = draw.RoundedBox
local PlaySound
PlaySound = surface.PlaySound
local Colors = {
  cfcPrimary = Color(36, 41, 67, 255)
}
local StatusPanel = {
  Init = function(self)
    local w, h = 512, 192
    local xPos = ScrW() - w - 32
    local yPos = ScrH() - h - 32
    self:SetTitle("")
    self:SetPos(xPos, yPos)
    self:SetSize(w, h)
    self:SetDraggable(false)
    self:DockPadding(16, 16, 16, 16)
    self:ShowCloseButton(true)
    self.label = nil
  end,
  Paint = function(self, w, h)
    return RoundedBox(8, 0, 0, w, h, Colors.cfcPrimary)
  end,
  Clear = function(self)
    if self.label then
      self.label:Remove()
    end
    if self.loading then
      self.loading:Remove()
    end
    if self.success then
      self.success:Remove()
    end
    if self.failure then
      return self.failure:Remove()
    end
  end,
  SetLoading = function(self)
    self:Clear()
    do
      local _with_0 = vgui.Create("DLabel", self)
      _with_0:Dock(TOP)
      _with_0:SetText("Waiting for a response...")
      _with_0:SetFont("GmodSudo_SudoStandardFont")
      self.label = _with_0
    end
    do
      local _with_0 = vgui.Create("DImage", self)
      _with_0:SetImage("gm_sudo/hourglass.png")
      _with_0:SetSize(100, 100)
      _with_0:Center()
      self.success = _with_0
    end
  end,
  SetSuccess = function(self)
    self:Clear()
    local animationTime = 2
    do
      local _with_0 = vgui.Create("DImage", self)
      _with_0:SetImage("gm_sudo/success.png")
      _with_0:SetSize(150, 136)
      _with_0:Center()
      _with_0:SetAlpha(0)
      _with_0:AlphaTo(255, animationTime * 0.66, 0, function()
        return PlaySound("gm_sudo/access_granted.mp3")
      end)
      self.success = _with_0
    end
    return timer.Create("GmodSudo_SuccessDestroyTimer", animationTime, 1, function()
      return self:AlphaTo(0, 0.75, 0, function()
        return self:Remove()
      end)
    end)
  end
}
return vgui.Register("GmodSudo_StatusPanel", StatusPanel, "DFrame")
