import "../extension/finalizablecrowdsale.lua"
import "../extension/cappedcrowdsale.lua"

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