local duration = CreateConVar("gm_sudo_session_length", 30 * 60, FCVAR_REPLICATED, "How many seconds should each Sudo session last", 0)
local SudoManager
do
  local _class_0
  local _base_0 = {
    _wrap = function(self, func, returnValue)
      if returnValue == nil then
        returnValue = true
      end
      local playerMeta = FindMetaTable("Player")
      local original = playerMeta[func]
      playerMeta[func] = function(ply)
        local steamId = ply:SteamID64()
        local expiration = self.sessions[steamId]
        if not (expiration) then
          return original(ply)
        end
        if not (os.time() >= expiration) then
          return returnValue
        end
        self.sessions[steamId] = nil
        return original(ply)
      end
    end,
    _wrapFunctions = function(self)
      self:_wrap("IsAdmin")
      self:_wrap("IsSuperAdmin")
      if SERVER then
        self:_wrap("GetUserGroup", "superadmin")
      end
      self.wrapped = true
    end,
    add = function(self, ply)
      if not (self.wrapped) then
        self:_wrapFunctions()
      end
      self.sessions[ply:SteamID64()] = os.time() + self.duration
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.sessions = { }
      self.wrapped = false
      self.duration = duration:GetInt()
    end,
    __base = _base_0,
    __name = "SudoManager"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  SudoManager = _class_0
end
return SudoManager()
