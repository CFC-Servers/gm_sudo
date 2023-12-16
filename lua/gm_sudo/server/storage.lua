local TableExists, Query, QueryRow, SQLStr
do
  local _obj_0 = sql
  TableExists, Query, QueryRow, SQLStr = _obj_0.TableExists, _obj_0.Query, _obj_0.QueryRow, _obj_0.SQLStr
end
local format
format = string.format
local Logger
Logger = Sudo.Logger
local UserStorage
do
  local _class_0
  local _base_0 = {
    initTable = function(self)
      Logger:debug("Running DB setup...")
      return Query(format([[            CREATE TABLE IF NOT EXISTS %s(
                steam_id TEXT    PRIMARY KEY NOT NULL,
                digest   TEXT    NOT NULL,
                salt     TEXT
                active   BOOLEAN DEFAULT 1
            )
        ]], self.tableName))
    end,
    store = function(self, steamId, digest, salt)
      Logger:debug("Storing: " .. tostring(steamId) .. " | " .. tostring(digest) .. " | " .. tostring(salt))
      local result = Query(format([[            INSERT OR REPLACE INTO %s (steam_id, digest, salt) VALUES(%s, %s, %s)
        ]], self.tableName, SQLStr(steamId), SQLStr(digest), SQLStr(salt)))
      if result == false then
        return error(sql.LastError())
      else
        return result
      end
    end,
    delete = function(self, steamId)
      Logger:debug("Deleting: " .. tostring(steamId))
      local result = Query(format([[            DELETE FROM %s
            WHERE steam_id = %s
        ]], self.tableName, SQLStr(steamId)))
      if result == false then
        return error(sql.LastError())
      else
        return result
      end
    end,
    get = function(self, steamId)
      Logger:debug("Getting: " .. tostring(steamId))
      local result = QueryRow(format([[            SELECT digest, salt
            FROM %s
            WHERE steam_id = %s
        ]], self.tableName, SQLStr(steamId)))
      if result == false then
        return error(sql.LastError())
      else
        return result
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.tableName = SQLStr("gm_sudo_users")
      return hook.Add("PostGamemodeLoaded", "GmodSudo_DBInit", function()
        return self:initTable()
      end)
    end,
    __base = _base_0,
    __name = "UserStorage"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  UserStorage = _class_0
end
return UserStorage()
