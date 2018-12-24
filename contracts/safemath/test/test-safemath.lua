local filepath, filename, fileext = string.match(arg[0], "(.-)([^\\]-([^\\%.]+))$")
package.path = filepath .. '../../../libs/?.lua;' .. filepath .. '../?.lua;'.. package.path

require "athena-343-local"
require "safemath"

local suite = TestSuite('test suite for safemath.lua')

suite:add(TestCase('test add', function()
      assertEquals(7, safemath.add(3, 4))
    end))

suite:add(TestCase('test sub', function()
      assertEquals(5, safemath.sub(7, 2))
    end))

suite:add(TestCase('test sub abnormal', function()
      local ret, data = pcall(function() safemath.sub(3, 7) end)
      assertFalse(ret)

    end))

suite:add(TestCase('test mul', function()
      assertEquals(14, safemath.mul(7, 2))
    end))

suite:add(TestCase('test mul abnormal', function()
      local biggestNum = 0
      for i = 971, 1023 do
        biggestNum = biggestNum + (2 ^ i)
      end
      local ret, data = pcall(function() safemath.mul(biggestNum, 2) end)
      assertFalse(ret)

    end))

suite:add(TestCase('test div', function()
      assertEquals(5, safemath.div(10, 2))
    end))

suite:run()
