import "../crowdsale.lua"

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