import "aergo-contract-ex/typecheck"
import "aergo-contract-ex/object"

------------------------------------------------------------------------------
-- From ERC20 Token Contract
-- @see https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20
------------------------------------------------------------------------------

local function _approveKeyGen(requester, spender) 
  return requester .. "->" .. spender
end

_transfer = typecheck('address', 'address', 'bignum')(function (from, to, value)
  assert(value > bignum.number(0), "transfer value must be bigger than 0")
  assert(_balances[from] and value <= _balances[from], "not enough balance")

  _balances[from] = _balances[from] - value
  _balances[to] = (_balances[to] or bignum.number(0)) + value

  -- TODO event notification
  system.print(string.format("transfer %s -> %s: %s", from, to, value))
end)

state.var {
  _balances = state.map(), -- address => bignum
  _allowed = state.map(), -- (address->address) => bignum
  _totalSupply = state.value(), -- bignum
}

Token = Object({
  ---------------------------------------
  -- Internal function to mint an amount of the token to an account
  -- @type internal
  -- @param account  an address that will receive the minted token
  -- @param value    an amount of token to mint
  ---------------------------------------
  mint = typecheck('address', 'bignum')(function (to, value)
    assert(value > bignum.number(0), "mint value must be bigger than 0")
    _totalSupply:set(_totalSupply:get() or bignum.number(0) + value)
    
    _balances[to] = (_balances[to] or bignum.number(0)) + value
  end),
    
  burn = typecheck('address', 'bignum')(function (to, value)
    assert(value > bignum.number(0), "mint value must be bigger than 0")
    assert(_balances[to] >= value, "value cannot be bigger than a receiver's balance")
    
    _totalSupply:set(_totalSupply:get() - value)
    
    _balances[to] = _balances[to] - value
  end),

  burnFrom = typecheck('address', 'bignum')(function (to, value)
    local key = _approveKeyGen(to, system.getSender())
    local allowedToken = _allowed[key] or bignum.number(0)
    assert(value <= allowedToken, "not enough allowed balance")
    
    _allowed[key] = allowedToken - value
    
    burn(to, value)
  end),

  ---------------------------------------
  -- Get a total token supply.
  -- @type query
  -- @param id Session identification.
  -- @return  total supply of this token
  ---------------------------------------
  totalSupply = typecheck('->', 'bignum')(function()
    return _totalSupply:get()
  end),

  ---------------------------------------
  -- Get a balance of an owner.
  -- @type    query
  -- @param   owner a target address
  -- @return  balance of owner
  ---------------------------------------
  balanceOf = typecheck('address', '->', 'bignum')(function (owner)      
    return _balances[owner] or bignum.number(0)
  end),

  ---------------------------------------
  -- Get an amount of allowance from owner to spender
  -- @type query
  -- @param owner     owner address
  -- @param spender   allowed address
  -- @return          amount of approved balance between 2 addresses
  ---------------------------------------
  allowance = typecheck('address', 'address', '->', 'bignum')(function (owner, spender)
    local key = _approveKeyGen(owner, spender)  
    return _allowed[key] or bignum.number(0)
  end),

  ---------------------------------------
  -- Transfer sender's token to target 'to'
  -- @type call
  -- @param to    a target address
  -- @param       value an amount of token to send
  -- @return      success
  ---------------------------------------
  transfer = typecheck('address', 'bignum', '->', 'boolean')(function (to, value) 
    _transfer(system.getSender(), to, value)
    
    return true
  end),

  ---------------------------------------
  -- Allow spender to use this amount of value of token
  -- @type call
  -- @param spender   a spender's address
  -- @param value     an amount of token to approve
  -- @return      success
  ---------------------------------------
  approve = typecheck('address', 'bignum', '->', 'boolean')(function (spender, value) 
    local key = _approveKeyGen(system.getSender(), spender)
  
    _allowed[key] = value
  
    -- TODO event notification
    system.print(string.format("approve %s: %s", key, bvalue))
    
    return true
  end),

  ---------------------------------------
  -- Transfer 'from's token to target 'to'. 
  -- A this function sender have to be approved to spend the amount of value from 'from'
  -- @type call
  -- @param from  a sender's address
  -- @param to    a receiver's address
  -- @param value an amount of token to send
  ---------------------------------------
  transferFrom = typecheck('address', 'address', 'bignum', '->', 'boolean')(function (from, to, value)
    local key = _approveKeyGen(from, system.getSender())
    local allowedToken = _allowed[key] or bignum.number(0)
    assert(value <= allowedToken, "not enough allowed balance")
    
    _allowed[key] = allowedToken - value

    _transfer(from, to, value)
    
    return true
  end)
})