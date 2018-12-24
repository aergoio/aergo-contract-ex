local filepath, filename, fileext = string.match(arg[0], "(.-)([^\\]-([^\\%.]+))$")
package.path = filepath .. '../../../libs/?.lua;' .. filepath .. '../?.lua;'.. package.path

require "athena-343-local"
require "mycrowdsale"

local suite = TestSuite('test suite for mycrowdsale.lua')

suite:add(TestCase('test buyTokens', function()
    local _tokenAddr = "token_address"
    local _sender = "AmhUthrLULUMee46RDcfmBfajd3CK7Lpbgds7xRsAQoLpY32BcFK"
    local _collector = "aergo collector"
    -- set internal parameters
    mycrowdsale.rate:set(5)
    mycrowdsale.token:set(_tokenAddr)
    mycrowdsale.collector:set(_collector)
    
    local function reset() 
        mycrowdsale.rate:set(0)
        mycrowdsale.token:set('')
        mycrowdsale.collector:set('')
    end

    -- set mockup function
    function system.getSender() return _sender end
    function system.getAmount() return 10000 end

    -- check token transfer
    function contract.call(tokenAddress, functionName, buyer, amount) 
        assertEquals(tokenAddress, _tokenAddr)
        assertEquals(functionName, "transfer")
        assertEquals(buyer, _sender)
        assertEquals(amount, 50000)
    end
    -- check aergo transfer
    function contract.send(collector, amount) 
        assertEquals(_collector, collector)
        assertEquals(amount, 10000)
    end

    payable()
    
    reset() 
    end))

suite:add(TestCase('test _preValidatePurchase when reach cap', function()
    local _buyer = "AmhUthrLULUMee46RDcfmBfajd3CK7Lpbgds7xRsAQoLpY32BcFK"
    local _aergoAmount = 500

    -- test success
    cappedcrowdsale.cap:set(100000)
    cappedcrowdsale.raised:set(99499) -- raised does not exceed cap
    
    local function reset() 
        cappedcrowdsale.cap:set(0)
        cappedcrowdsale.raised:set(0)
    end
    
    local ret, msg = pcall(function() cappedcrowdsale:_preValidatePurchase(_buyer, _aergoAmount) end)
    assertTrue(ret) 

    -- test fail case
    cappedcrowdsale.cap:set(100000)
    cappedcrowdsale.raised:set(110000) -- raised exceeds cap
  
    local ret, msg = pcall(function() cappedcrowdsale:_preValidatePurchase(_buyer, _aergoAmount) end)
    assertFalse(ret) 
    local _error_msg = "reach cap"
    assertTrue(msg:sub(-#_error_msg) == _error_msg)  -- check error type

    reset() 
end))


suite:add(TestCase('test _preValidatePurchase when reach time', function()
    local _buyer = "AmhUthrLULUMee46RDcfmBfajd3CK7Lpbgds7xRsAQoLpY32BcFK"
    local _aergoAmount = 500

    timedcrowdsale.openingTime:set(1)
    timedcrowdsale.closingTime:set(20)

    local function reset() 
        timedcrowdsale.openingTime:set(0)
        timedcrowdsale.closingTime:set(0)
    end

    function system.getBlockheight() return 100 end

    local ret, msg = pcall(function() timedcrowdsale:_preValidatePurchase(_buyer, _aergoAmount) end)
    assertFalse(ret) 
    local _error_msg = "reach closing time"
    assertTrue(msg:sub(-#_error_msg) == _error_msg) -- check error type

    reset() 
end))
    
suite:run()