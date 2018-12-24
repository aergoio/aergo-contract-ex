import "../crowdsale.lua"

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