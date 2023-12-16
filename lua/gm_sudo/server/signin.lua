local Logger
Logger = Sudo.Logger
local ExchangeManager = include("lib/exchange_manager.lua")
local Encryption = include("encryption.lua")
local UserStorage = include("storage.lua")
local NetMessages = include("gm_sudo/shared/net_messages.lua")
local SignInManager
do
  local _class_0
  local _parent_0 = ExchangeManager
  local _base_0 = {
    _timerName = function(self, target)
      return "GmodSudo_SignInTimeout_" .. tostring(target:SteamID64())
    end,
    _verifyPassword = function(self, target, password)
      Logger:info("Verifying password in SignInManager for " .. tostring(target))
      target = target:SteamID64()
      local data = UserStorage:get(target)
      return Encryption:verify(password, data.digest, data.salt)
    end,
    receiveResponse = function(self, target)
      Logger:info("Received response in SignInManager for " .. tostring(target))
      local passesValidations = _class_0.__parent.__base.receiveResponse(self, target) == true
      if passesValidations then
        local validPassword = self:_verifyPassword(target, net.ReadString())
        Logger:debug("Passes validations")
        if validPassword then
          Logger:info("Given a valid password, allowing access to " .. tostring(target))
          self:remove(target)
          return self:onSuccess(target)
        end
      end
      Logger:warn("Validations did not pass or given password was incorrect, failed attempt")
      self:onFailedAttempt(target)
      return self:start(target)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.sessionLifetime = 60
      self.promptMessage = NetMessages.signInRequest
      self:_createListener()
      return self:_createThrottleTimer()
    end,
    __base = _base_0,
    __name = "SignInManager",
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
  SignInManager = _class_0
end
return SignInManager()
