
state.var {
  TokenAddr = state.value()
}
-- set token address to use
function constructor(tokenContractAddress) 
  assert(tokenContractAddress ~= nil)
  TokenAddr:set(tokenContractAddress)
end

-- call this and token2aergo through approveCall of a token contract
-- e.g. token_contract.call('approveAndCall', 'this_contract_addr', amount, 'token2aergo')
function receiveApproval(msgSenderAddr, amount, ...)
  local tokenAddr = system.getSender()
  
  assert(tokenAddr == TokenAddr:get(), "Not Registered Token")
  
  local args = {...}
  assert(table.getn(args) > 0, "No target function specified")
  local funcName = args[1]
  
  _G[funcName](msgSenderAddr, amount, unpack(args, 2, table.getn(args)))
end

-- first need to approve required amount of token to this contract
-- e.g. token_contract.call('approve', 'this_contract_addr', amount)
function token2aergo(msgSenderAddr, amount)

  local bamount = bignum.number(amount)  

  local tokenAddr = system.getSender()
  local thisAddr = system.getContractID()

  assert(tokenAddr == TokenAddr:get(), "Not Registered Token")

  local senderToken = contract.call(tokenAddr, "balanceOf", msgSenderAddr)
  assert(bamount <= senderToken, string.format("Not enough token at sender. require: %s, current: %s", bamount, senderToken))

  -- send token from the sender to this contract
  contract.call(tokenAddr, "transferFrom", msgSenderAddr, thisAddr, amount)

  -- send aergo from this contract to the sender
  contract.send(msgSenderAddr, bamount)
end


-- deposit a sender's aergo to this contract
-- and send this contract's token to the sender
function aergo2token() 

  local tokenAddr = TokenAddr:get()
  local senderAddr = system.getSender()
  local thisAddr = system.getContractID()

  local thisToken = contract.call(tokenAddr, "balanceOf", thisAddr)
  local bamount = bignum.number(system.getAmount())

  assert(bamount <= thisToken, string.format("Not enough token at contract. require: %s, current: %s", bamount, thisToken))

  -- send this contract's token to the sender
  contract.call(tokenAddr, "transfer", senderAddr, bamount)
end

-- fallback func
function default()
  aergo2token() 
end

abi.payable(aergo2token, default)
abi.register(receiveApproval, token2aergo)
