import "aergo-contract-ex/safemath"
import "aergo-contract-ex/address"
import "aergo-contract-ex/object"

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