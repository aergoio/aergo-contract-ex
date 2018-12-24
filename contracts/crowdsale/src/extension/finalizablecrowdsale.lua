import "./timedcrowdsale.lua"

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
