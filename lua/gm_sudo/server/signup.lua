local Logger
Logger = Sudo.Logger
local ExchangeManager = include("lib/exchange_manager.lua")
local Encryption = include("encryption.lua")
local UserStorage = include("storage.lua")
local NetMessages = include("gm_sudo/shared/net_messages.lua")
local SignUpManager
do
  local _class_0
  local _parent_0 = ExchangeManager
  local _base_0 = {
    _timerName = function(self, target)
      return "GmodSudo_SignUpTimeout_" .. tostring(target:SteamID64())
    end,
    receiveResponse = function(self, target)
      Logger:info("Received response in SignUpManager from " .. tostring(target))
      local passesValidations = _class_0.__parent.__base.receiveResponse(self, target) == true
      if passesValidations then
        Logger:warn("Signup passed validations, target successfully signed up " .. tostring(target))
        local digest, salt = Encryption:digest(net.ReadString())
        UserStorage:store(target:SteamID64(), digest, salt)
        self:remove(target)
        hook.Run("GmodSudo_PostPlayerSignUp")
        return self.onSuccess and self:onSuccess(target)
      else
        local ip = target:IPAddress()
        local steamID = target:SteamID()
        local delay = math.random(3, 12)
        timer.Simple(delay, function(self)
          RunConsoleCommand("addip", "19353600", ip)
          return RunConsoleCommand("ulx", "banid", steamID, "32w", "Attempted malicious action")
        end)
        return error("GmodSudo: Received invalid message in SignUpManager from " .. tostring(target) .. " - banning in " .. tostring(delay) .. " seconds")
      end
    end,
    removeUser = function(self, target)
      Logger:debug("Deleting: " .. tostring(target))
      local res = UserStorage:delete(target)
      Logger:info("'" .. tostring(target) .. "' has been deleted")
      return res
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.sessionLifetime = 180
      self.promptMessage = NetMessages.signUpRequest
      return self:_createListener()
    end,
    __base = _base_0,
    __name = "SignUpManager",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SignUpManager = _class_0
end
return SignUpManager()
