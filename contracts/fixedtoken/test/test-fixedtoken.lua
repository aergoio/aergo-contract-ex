local filepath, filename, fileext = string.match(arg[0], "(.-)([^\\]-([^\\%.]+))$")
package.path = filepath .. '../../../libs/?.lua;' .. filepath .. '../?.lua;'.. package.path


require "athena-343-local"
require "fixedtoken"

local suite = TestSuite('test suite for fixedtoken.lua')

suite:add(TestCase('test totalSupply', function()
      function system.getCreator() 
        return "AmhUthrLULUMee46RDcfmBfajd3CK7Lpbgds7xRsAQoLpY32BcFK" 
      end
        
      constructor()
      assertEquals(5000000000000000000, totalSupply() )
    end))
    
suite:add(TestCase('test transfer', function()
      local sender = "AmhUthrLULUMee46RDcfmBfajd3CK7Lpbgds7xRsAQoLpY32BcFK"
      local receiver = "AmgR34MnJ1XgvVTtL2FudQBp8wQvfP9voHCyYjWcTKcJUEU5FGGu"
      function system.getCreator() return sender end
      function system.getSender() return sender end
      constructor()
      transfer(receiver, 7777)

      assertEquals(7777, balanceOf(receiver))
    end))

suite:run()