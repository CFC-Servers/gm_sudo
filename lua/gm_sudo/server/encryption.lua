local Base64Encode
Base64Encode = util.Base64Encode
local Exists, Read, Write
do
  local _obj_0 = file
  Exists, Read, Write = _obj_0.Exists, _obj_0.Read, _obj_0.Write
end
local Logger
Logger = Sudo.Logger
local encryptionSetting = CreateConVar("gm_sudo_encryption_method", "sha512", FCVAR_PROTECTED + FCVAR_ARCHIVE)
local EncryptionInterface
do
  local _class_0
  local _base_0 = {
    encrypt = function(self, data)
      return self.sha[encryptionSetting:GetString()](data)
    end,
    digest = function(self, password)
      Logger:debug("Generating digest")
      local generatedSalt = Base64Encode(self.random.bytes(64))
      return self:encrypt(tostring(password) .. tostring(generatedSalt)), generatedSalt
    end,
    verify = function(self, password, digest, salt)
      if salt == nil then
        salt = ""
      end
      return digest == self:encrypt(tostring(password) .. tostring(salt))
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.random = include("lib/random.lua")
      self.sha = include("includes/modules/sha2.lua")
    end,
    __base = _base_0,
    __name = "EncryptionInterface"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  EncryptionInterface = _class_0
end
return EncryptionInterface()
