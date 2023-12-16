local Base64Encode
Base64Encode = util.Base64Encode
local Logger
Logger = Sudo.Logger
local Random = include("random.lua")
local ExchangeManager
do
  local _class_0
  local _base_0 = {
    _createListener = function(self)
      Logger:debug("Creating net listener for: " .. tostring(self.promptMessage))
      return net.Receive(self.promptMessage, function(_, ply)
        return self:receiveResponse(ply)
      end)
    end,
    _timerName = function(self, target)
      return error("NotImplemented")
    end,
    _generateToken = function(self)
      return Base64Encode(Random.bytes(self.tokenSize))
    end,
    _createThrottleTimer = function(self)
      return timer.Create(tostring(self.promptMessage) .. "_throttle", self.throttleTime, 0, function()
        self.throttle = { }
      end)
    end,
    _createRemovalTimer = function(self, target)
      Logger:debug("Creating removal timer for: " .. tostring(target))
      return timer.Create(self:_timerName(target), self.sessionLifetime, 1, function()
        return self:remove(target)
      end)
    end,
    _stopRemovalTimer = function(self, target)
      Logger:debug("Stopping removal timer for: " .. tostring(target))
      return timer.Remove(self:_timerName(target))
    end,
    _sendPrompt = function(self, target)
      Logger:debug("Sending prompt for: " .. tostring(target))
      local attempts, token, lifetime
      do
        local _obj_0 = self.sessions[target:SteamID64()]
        attempts, token, lifetime = _obj_0.attempts, _obj_0.token, _obj_0.lifetime
      end
      net.Start(self.promptMessage)
      net.WriteString(token)
      net.WriteUInt(lifetime, 8)
      net.WriteUInt(self.maxAttempts, 3)
      net.WriteUInt(attempts, 3)
      return net.Send(target)
    end,
    _verifySession = function(self, target)
      Logger:debug("Verifying session for: " .. tostring(target))
      target = target:SteamID64()
      local session = self.sessions[target]
      if session then
        return true
      end
      ErrorNoHaltWithStack("No session for given target: " .. tostring(target))
      return false
    end,
    _verifyLifetime = function(self, target)
      Logger:debug("Verifying lifetime for: " .. tostring(target))
      local targetSteamID = target:SteamID64()
      local session = self.sessions[targetSteamID]
      local sessionExpiration = session.sent + session.lifetime
      if os.time() < sessionExpiration then
        return true
      end
      Logger:warn("Session expired for " .. tostring(targetSteamID))
      self:remove(target)
      return false
    end,
    _verifyAttempts = function(self, target)
      Logger:debug("Verifying attempts for: " .. tostring(target))
      local targetSteamID = target:SteamID64()
      local session = self.sessions[targetSteamID]
      return session.attempts < self.maxAttempts
    end,
    _verifyToken = function(self, target)
      local givenToken = net.ReadString()
      Logger:debug("Verifying token for: " .. tostring(target) .. ", '" .. tostring(givenToken) .. "'")
      target = target:SteamID64()
      local expected = self.sessions[target].token
      if givenToken == expected then
        return true
      end
      ErrorNoHaltWithStack("Invalid token given! Expected '" .. tostring(expected) .. "'. Received: '" .. tostring(givenToken) .. "'")
      return false
    end,
    start = function(self, target)
      Logger:debug("Starting exchange session for: " .. tostring(target))
      if not (IsValid(target)) then
        return 
      end
      local targetSteamID = target:SteamID64()
      local throttleCount = self.throttle[targetSteamID] or 0
      if throttleCount > self.throttleAmount then
        return Logger:warn("Player exceeded rate limit, ignoring: " .. tostring(target))
      end
      self.throttle[targetSteamID] = throttleCount + 1
      local existing = self.sessions[targetSteamID]
      local attempts = existing and existing.attempts or -1
      attempts = attempts + 1
      local token = self:_generateToken()
      local lifetime = self.sessionLifetime
      local sent = os.time()
      self.sessions[targetSteamID] = {
        attempts = attempts,
        token = token,
        lifetime = lifetime,
        sent = sent
      }
      return self:_sendPrompt(target)
    end,
    remove = function(self, target)
      Logger:debug("Removing exchange session for: " .. tostring(target))
      self:_stopRemovalTimer(target)
      self.sessions[target:SteamID64()] = nil
    end,
    receiveResponse = function(self, target)
      Logger:debug("Received exchange response for: " .. tostring(target))
      if not (self:_verifySession(target)) then
        return false
      end
      self:_stopRemovalTimer(target)
      if not self:_verifyAttempts(target) then
        self:remove(target)
        self:onFailure(target, "Too many failed attempts!")
        error("Too many failed attempts for " .. tostring(target) .. "!")
      end
      if not (self:_verifyLifetime(target)) then
        return false
      end
      if not (self:_verifyToken(target)) then
        return false
      end
      return true
    end,
    onSuccess = function(self)
      return error("NotImplemented")
    end,
    onFailedAttempt = function(self)
      return error("NotImplemented")
    end,
    onFailure = function(self)
      return error("NotImplemented")
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.sessions = { }
      self.maxAttempts = 3
      self.tokenSize = 32
      self.sessionLifetime = 120
      self.promptMessage = nil
      self.throttle = { }
      self.throttleAmount = 2
      self.throttleTime = 1
    end,
    __base = _base_0,
    __name = "ExchangeManager"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ExchangeManager = _class_0
end
return ExchangeManager
