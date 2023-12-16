local random
random = math.random
local Random
do
  local _class_0
  local _base_0 = {
    bytes = function(length)
      return string.char(unpack((function()
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, length do
          _accum_0[_len_0] = random(0, 255)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)()))
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Random"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Random = _class_0
end
return Random()
