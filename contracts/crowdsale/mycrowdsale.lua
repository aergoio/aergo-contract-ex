---------------------------------------
-- an utility function to represent behavior of class
-- @param   ... list of a table, which has field list, and objects to inheritent
-- @return      new object
---------------------------------------
function Object(...)
  local obj = {}
  
  -- copy all of parents and fields
  for i, parent in pairs({...}) do 
    for k, v in pairs(parent) do
      if(k ~= '__index') then 
        obj[k] = v         
      end
    end
  end
  
  -- set parent's meta
  obj.__index = obj 
  
  return obj
end
--- a simple utility to handle addresses
-- @module address

address = {}

---------------------------------------
-- Check address correctness
-- @type query
-- @param address address to check
-- @return  boolean valid or not
---------------------------------------
function address.isValidAddress(address)
  -- check existence of invalid alphabets
  if nil ~= string.match(address, '[^123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]') then
    return false
  end

  -- check length is in range
  if 52 ~= string.len(address) then
    return false
  end

  return true
end

---------------------------------------
-- Get nil address, used to burn token
-- @type query
-- @return  nil address
---------------------------------------
function address.nilAddress()
  return "1111111111111111111111111111111111111111111111111111"
end

--- a simple safe math library
-- @see https://github.com/bokkypoobah/Tokens/blob/master/contracts/SafeMth.sol
-- @module safemath

safemath = {}

-- big number api
function safemath.add(a, b) 
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)

  local c = a + b
  assert(bignum.compare(c, a) >= 0)
  
  return c
end

function safemath.sub(a, b) 
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)

  assert(bignum.compare(b, a) <= 0, "first value must be bigger than second")
  local c = a - b

  return c
end

function safemath.mul(a, b) 
  a = bignum.number(a or 0)  
  -- when a == 0
  if bignum.compare(a, 0) == 0 then 
    return bignum.number(0)
  end
  
  b = bignum.number(b or 0)
  
  local c = a * b
  assert(c/a == b, "overflow")
  
  return c
end

function safemath.div(a, b)
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)
   
  assert(bignum.compare(b, 0) > 0, "divide by zero")
  c = a / b

  return c
end  

function safemath.mod(a, b)
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)
  
  assert(bignum.compare(b, 0) ~= 0, "divide by zero")
  c = a % b

  return c
end

---------------------------------------
-- crowdsale object definition
-- @see https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/crowdsale/Crowdsale.sol
---------------------------------------

state.var {
  Token = state.value(),
  Collector = state.value(),
  Book = state.map(),
  Rate = state.value(),
  Raised = state.value()
}

crowdsale = Object({
    token = Token,
    collector= Collector,
    book = Book,
    rate = Rate,
    raised = Raised,

    initialize = function(self, rate, collectorAddress, tokenAddress)
      assert(rate > 0)
      assert(address.isValidAddress(collectorAddress) and collectorAddress ~= address.nilAddress())
      assert(address.isValidAddress(tokenAddress) and tokenAddress ~= address.nilAddress())

      self.rate:set(rate)
      self.collector:set(collectorAddress)
      self.token:set(tokenAddress)
      self.raised:set(0)
    end,

    _preValidatePurchase = function(self, buyer, aergoAmount)
      assert(buyer ~= address.nilAddress())
      -- aergoAmount must be bigger than 0
      assert(bignum.compare(aergoAmount, 0) == 1)
    end,

    _postValidatePurchase = function(self, buyer, aergoAmount)
      -- optional
    end,

    _deliverTokens = function(self, buyer, tokenAmount)
      contract.call(self.token:get(), "transfer", buyer, tokenAmount)
    end,

    _processPurchase = function(self, buyer, tokenAmount)
      self:_deliverTokens(buyer, tokenAmount)
    end,

    _updatePurchasingState = function(self, buyer, aergoAmount)
      -- optional
    end,

    _getTokenAmount = function(self, aergoAmount)
      return safemath.mul(aergoAmount, self.rate:get())
    end,

    _forwardFunds = function(self)
      contract.send(self.collector:get(), system.getAmount())
    end,

    -- do not override this
    buyTokens = function(self, buyer) 

      local aergoAmount = bignum.number(system.getAmount())
      self:_preValidatePurchase(buyer, aergoAmount)

      -- calculate token amount to be created
      local tokenAmount = self:_getTokenAmount(aergoAmount)

      -- update state
      self.raised:set(safemath.add(self.raised:get(), aergoAmount))

      self:_processPurchase(buyer, tokenAmount)

      -- TODO event notification

      self:_updatePurchasingState(buyer, tokenAmount)

      self:_forwardFunds()

      self:_postValidatePurchase(buyer, tokenAmount)
    end
  })

---------------------------------------
-- crowdsale external functions
---------------------------------------

-- implement this
--[[
function default() 
   crowdsale:buyTokens(system.getSender())
end

abi.payable(default)
]]--

function token()
  return crowdsale.token:get()
end

function wallet()
  return crowdsale.collector:get()
end

function rate()
  return crowdsale.rate:get()
end

function raised()
  return crowdsale.raised:get()
end

abi.register(token, wallet, rate, raised)

---------------------------------------
-- capped crowdsale object definition
-- @see https://github.com/OpenZeppelin/openzeppelin-solidity/tree/master/contracts/crowdsale/validation
---------------------------------------

state.var {
  Cap = state.value()
}

cappedcrowdsale = Object(crowdsale, {
    cap = Cap,
    
    initialize = function(self, capArg)
      local bcap = bignum.number(capArg)
      assert(bcap > bignum.number(0))
      self.cap:set(bcap)
    end,

    _preValidatePurchase = function(self, buyer, aergoAmount)
      crowdsale:_preValidatePurchase(buyer, aergoAmount)
      assert(safemath.add(raised(), aergoAmount) <= self.cap:get(), "reach cap")
    end
})

---------------------------------------
-- capped crowdsale external functions
---------------------------------------

function cap()
  return cappedcrowdsale.cap:get()
end

function capReached()
  return raised() >= cap()
end

abi.register(cap, capReached)


---------------------------------------
-- timed crowdsale object definition
-- @see https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/crowdsale/validation/TimedCrowdsale.sol
---------------------------------------

state.var {
  OpeningTime = state.value(),
  ClosingTime = state.value()
}

timedcrowdsale = Object(crowdsale, {
    openingTime = OpeningTime,
    closingTime = ClosingTime,

    initialize = function(self, openingBlockNum, closingBlockNum)
      assert(openingBlockNum >= system.getBlockheight())
      assert(closingBlockNum > openingBlockNum)

      self.openingTime:set(openingBlockNum)
      self.closingTime:set(closingBlockNum)
    end,

    _preValidatePurchase = function(self, buyer, aergoAmount)
      crowdsale:_preValidatePurchase(buyer, aergoAmount)
      assert(isOpen(), "reach closing time")
    end
  })

---------------------------------------
-- timed crowdsale external functions
---------------------------------------

function openingTime()
  return timedcrowdsale.openingTime:get()
end

function closingTime()
  return timedcrowdsale.closingTime:get()
end

function isOpen()
  return (system.getBlockheight() >= openingTime() and 
        system.getBlockheight() <= closingTime())
end

function hasClosed()
  return system.getBlockheight() > closingTime()
end

abi.register(openingTime, closingTime, isOpen, hasClosed)

---------------------------------------
-- finalizable crowdsale object definition
-- @see https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/crowdsale/distribution/FinalizableCrowdsale.sol
---------------------------------------

state.var {
  Finalized = state.value()
}

finalizablecrowdsale = Object(timedcrowdsale, {
    finalized = Finalized,
    
    initialize = function(self)
      self.finalized:set(false)
    end
})

---------------------------------------
-- finalizable crowdsale external functions
---------------------------------------

function finalized()
  return finalizablecrowdsale.finalized:get()
end

function finalize()
  assert(not finalized())
  assert(hasClosed())
  
  finalizablecrowdsale.finalized:set(true)
end

abi.register(finalized, finalize)

---------------------------------------
-- timed crowdsale object definition
-- inherite capped and finalizable crowdsale
---------------------------------------

mycrowdsale = Object(cappedcrowdsale, finalizablecrowdsale, {

    initialize = function(self, startTime, endTime, rate, cap, collectorAddr, tokenAddr)
      crowdsale:initialize(rate, collectorAddr, tokenAddr)
      cappedcrowdsale:initialize(cap)
      timedcrowdsale:initialize(startTime, endTime)
      finalizablecrowdsale:initialize()
    end,

    _preValidatePurchase = function(self, buyer, aergoAmount)
      cappedcrowdsale:_preValidatePurchase(buyer, aergoAmount)
      timedcrowdsale:_preValidatePurchase(buyer, aergoAmount)
    end
  })

---------------------------------------
-- main contract
---------------------------------------

function constructor(startTime, endTime, rate, cap, collectorAddr, tokenAddr) 
  mycrowdsale:initialize(startTime, endTime, rate, cap, collectorAddr, tokenAddr)
end

function default() 
  mycrowdsale:buyTokens(system.getSender())
end

abi.payable(default)