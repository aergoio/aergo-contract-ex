--------------------------------------------------------------
--
-- Test framework for lua contract
--
color = {
  reset = string.char(27) .. '[0m',
  red = string.char(27) .. '[1;31m',
  green = string.char(27) .. '[1;32m',
  yellow = string.char(27) .. '[1;33m',
  blue = string.char(27) .. '[1;34m',
}

local fwstatus, framework = pcall(require, "ship.test.Athena")
if not fwstatus then
    TestReporter = {}
    
    function TestReporter.startTest(name)
      -- do nothing
    end
    
    function TestReporter.endTest(name)
      -- do nothing
    end
    
    function TestReporter.startSuite(name)
      print("===== Start Suite: " .. name .. " =====")
    end
     
    function TestReporter.endSuite(name)
      -- do nothing
    end
    
    function TestReporter.recordError(name, msg)
      print(color.red .. "[FAIL] " .. name .. " - " .. msg .. color.reset)
    end
    
    function TestReporter.pass(name)
      print(color.green .. "[PASS] " .. name .. color.reset)
    end
end

TestCase = { }
TestCaseMetatable = { __index = TestCase }
setmetatable(TestCase, {
  __call = function(cls, ...)
    return cls.new(...)
  end
})

function TestCase.new(name, runnable) 
  return setmetatable({
    name = name,
    runnable = runnable,
    error = nil
  }, TestCaseMetatable)
end

function TestCase:expected(error)
  self.error = error
  return self
end

function TestCase:run()
  TestReporter.startTest(self.name)
  if debug.traceback then
    result, err = xpcall(self.runnable, debug.traceback)
  else
    result, err = pcall(self.runnable)
  end
  if self.error then
    if err then
      local handledResult = self.error(err)
      if not handledResult then
        TestReporter.recordError(self.name, 'User unexpected error: ' .. err)
      end
    else
      TestReporter.recordError(self.name, 'No error')
    end
  elseif err then
    TestReporter.recordError(self.name, 'Unexpected error: ' .. err)
  else
    TestReporter.pass(self.name)
  end
  TestReporter.endTest(self.name)
end


TestSuite = { }
TestSuite.__index = TestSuite
setmetatable(TestSuite, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})
function TestSuite.new(name)
  local self = setmetatable({}, TestSuite)
  self.name = name
  self.testCases = {}
  return self
end

function TestSuite:run()
  local n = self.name
  TestReporter.startSuite(n)
  for name, testCase in pairs(self.testCases) do 
    testCase:run()
  end
  TestReporter.endSuite(self.name)
end
function TestSuite:add(testCase)
  local name = testCase.name
  self.testCases[name] = testCase
end

--------------------------------------------------------------
--
-- Mock-up for aergo server environment
--

if fwstatus then _G.print = nil end
_G.dofile = nil
_G.loadstring = nil
_G.loadfile = nil
_G.dofile = nil
_G.module = nil

system = {
    _m = {},
    getItem = function(key)
        return system._m[key]    
    end,
    setItem = function(key, value)
        system._m[key] = value
    end,    
    print = function(...)
      print(color.yellow .. '  ' .. ... .. color.reset) 
      end
}

abi = {
    register = function (funcname, ...)
    end,
    payable = function (funcname, ...)
    end
}

json = {
    encode = function(obj)
    end,
    decode = function(str)
    end
}

contract = {
    send = function (address, amount)
    end,
    delegatecall = function(address, funcname, ...) -- ... is function arguments
    end,
    pcall = function(func, ...) -- ... is function arguments
    end
}

db = {}

function db.exec(sql_stmt)
end

_rs_meta = {}
_rs_meta.__index = _rs_meta

function _rs_meta:next()
end

function _rs_meta:get()
end

function db.query(sql_stmt)
    return setmetatable({}, _rs_meta)
end

_pstmt_meta = {}
_pstmt_meta.__index = pstmt_meta

function _pstmt_meta:exec(...) -- ... is bind parameters
end

function _pstmt_meta:query(...) -- ... is bind parameters
    return setmetatable({}, _rs_meta)
end

function db.prepare(sql_stmt)
    return setmetatable({}, pstmt_meta)
end

state = {}

function state.var(tbl)
    for key, value in pairs(tbl) do
        value._id_ = key
        _G[key] = value
    end
end

_state_value_meta = {}
_state_value_meta.__index = _state_value_meta

function _state_value_meta:get()
    return self._val
end

function _state_value_meta:set(val)
    self._val = val
end

function state.value()
    return setmetatable({ _type_= "value" }, _state_value_meta)
end

function state.map_delete(self, key)
    self[key] = nil
end

function state.map()
    return { _type_ = "map", delete = state.map_delete }
end

function state.array_length(self)
    return self._len_
end

function state.array_iter(self)
    return self._len_
end

function state.array_iter(a, i)
    local n = i + 1
    if n <= a._len_ then
        return n, a[n]
    end
    return nil, nil
end

function state.array_ipairs(self)
    return state.array_iter, self, 0
end

function state.array(len)
    return { _type_ = "array", _len_ = len, length = state.array_length, ipairs = state.array_ipairs }
end

bignum = {}

function bignum.number(n)
  return tonumber(n)
end

function bignum.compare(n1, n2)
  if n1 > n2 then return 1 end
  if n1 < n2 then return -1 end
  
  return 0 
end

--------------------------------------------------------------
--
-- Utility for assertion
--
function assertTrue(exp, message)
  if exp then
    return
  end

  if message then
    error(message, 0)
  else
    error("expression must be true", 0)
  end
end

function assertFalse(exp, message)
  if not exp then
    return
  end

  if message then
    error(message, 0)
  else
    error("expression must be false", 0)
  end
end

function assertNotEquals(a, b, message)
  if actual ~= expected then
    return 
  end

  if message then
    error(message, 0)
  else
    error(tostring(actual) .. " is equal to " .. tostring(expected) .. ". Two value should not be equal.", 0)
  end

end

function assertEquals(expected, actual, message)
  if actual == expected then
    return 
  end

  if message then
    error(message, 0)
  else
    error(tostring(actual) .. " is not equal to " .. tostring(expected) .. ". Expected: " .. tostring(expected) .. ", Actual: " .. tostring(actual), 0)
  end
end

function assertNull(actual, message)
  if nil == actual then
    return 
  end

  if message then
    error(message, 0)
  else
    error(tostring(actual) .. " must be null", 0)
  end
end

function assertNotNull(actual, message)
  if nil ~= actual then
    return 
  end

  if message then
    error(message, 0)
  else
    error("value must not be null", 0)
  end
end