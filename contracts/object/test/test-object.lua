local filepath, filename, fileext = string.match(arg[0], "(.-)([^\\]-([^\\%.]+))$")
package.path = filepath .. '../../../libs/?.lua;' .. filepath .. '../?.lua;'.. package.path

require "athena-343-local"
require "object"

local suite = TestSuite('test suite for class.lua')

suite:add(TestCase('test normal', function()

      local base = Object({
          field1 = 1,
          func1 = function(self) return self.field1 end})

      assertEquals(1, base.field1)
      assertEquals(1, base:func1())

      base.field1 = 2
      assertEquals(2, base:func1())
    end))

suite:add(TestCase('test normal with state', function()

      state.var {
          field = state.value()
        }
        
      local base = Object({
          field1 = field,
          func1 = function(self) return self.field1:get() end})
      
      base.field1:set(1)
      assertEquals(1, base.field1:get())
      assertEquals(1, base:func1())
      
      base.field1:set(2)
      assertEquals(2, base:func1())
    end))

suite:add(TestCase('test inheritence', function()

      local base = Object({
          field1 = 1,
          func1 = function(self) return 1 end,
          funcFieldAccess = function(self) return self.field1 end,
          funcToOveride = function(self) return 1 end })

      local child = Object(base, {
          field1 = 2,
          func2 = function(self) return 2 end,
          funcFieldAccess = function(self) return self.field1 end,
          funcToOveride = function(self) return 2 end })

      assertEquals(1, base:func1())
      assertEquals(1, child:func1())
      
      assertNull(base.func2)
      assertEquals(2, child:func2())
      
      assertEquals(1, base:funcFieldAccess())
      assertEquals(2, child:funcFieldAccess())
      
      assertEquals(1, base:funcToOveride())
      assertEquals(2, child:funcToOveride())
    end))


suite:add(TestCase('test multiple inheritence', function()

      local base1 = Object({
          field1 = 1,
          fieldCollide = 1,
          func1 = function(self) return 1 end,
          funcCollide = function(self) return 1 end })
      
      local base2 = Object({
          field2 = 2,
          fieldCollide = 2,
          func2 = function(self) return 2 end,
          funcCollide = function(self) return 2 end })

      local child = Object(base1, base2, {
          field3 = 3,
          func3 = function(self) return 3 end,
          funcResolveCollide = function(self) 
            return base1:funcCollide() + base2:funcCollide()
          end })

      assertEquals(1, child.field1)
      assertEquals(2, child.field2)
      assertEquals(3, child.field3)
      
      assertEquals(1, child:func1())
      assertEquals(2, child:func2())
      assertEquals(3, child:func3())
      
      -- when collide, the last arg of Object() will remain
      assertEquals(2, child.fieldCollide) 
      assertEquals(2, child:funcCollide())
      
      assertEquals(3, child:funcResolveCollide())
    end))

suite:run()