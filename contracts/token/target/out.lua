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
-- from http://lua-users.org/wiki/LuaTypeChecking
--
-- Type check function that decorates functions.
-- supported type: string, number, function, boolean, nil, userdata, address, bignum
-- Example:
--   sum = typecheck('number', 'number', '->', 'number')(
--     function(x, y) return x + y end
--   )

function typecheck(...)
  local types = {...}
  
  local function check(x, f)
    local typeStr = type(x)
    
    if (x and f == 'address') then
      -- check address length
      assert(52 == #x, string.format("invalid address lenght: %s (%s)", x, #x))
      -- check character
      invalidChar = string.match(x, '[^123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]')
      assert(nil == invalidChar,
        string.format("invalid address format: %s contains invalid char %s", x, invalidChar))
    elseif (x and f == 'bignum') then
      -- check bignum
      assert(bignum.isbignum(x), string.format("invalid %s format: %s (type = %s)", f, x, type(x)))
    else
      -- check default lua types
      assert(type(x) == f, string.format("invalid %s format: %s (type = %s)", f, x, type(x)))
    end
  end
  
  return function(f)
    local function returncheck(i, ...)
      -- Check types of return values.
      if types[i] == "->" then i = i + 1 end
      local j = i
      while types[i] ~= nil do
        check(select(i - j + 1, ...), types[i])
        i = i + 1
      end
      return ...
    end
    return function(...)
      -- Check types of input parameters.
      local i = 1
      while types[i] ~= nil and types[i] ~= "->" do
        check(select(i, ...), types[i])
        i = i + 1
      end
      return returncheck(i, f(...))  -- call function
    end
  end
end

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



state.var{
    _minter = state.map(), -- string -> boolean
}

minterInit = function ()
	_minter[system.getCreator()] = true
end

isMinter = typecheck('address', '->', 'boolean')(function (account)
	return _minter[account] or false
end)

onlyMinter = function() 
	assert(isMinter(system.getSender()), 'minter only')
end

addMinter =  typecheck('address', '->')(function (account) onlyMinter()
	_minter[account] = true
end)

renounceMinter = function() 
	_minter[system.getSender()] = false
end


Mintable = Object(Token, {
  init = function()
    minterInit()
  end,

  mint = typecheck('address', 'bignum', '->', 'boolean')(function(to, value) onlyMinter()
    Token.mint(to, value)
    return true
  end) 
})



state.var {
  _meta = state.map(), -- string -> (string or number)
}

Detailed = Object(Token, {
  init = typecheck('string', 'string', 'number')(function (name, symbol, decimals)
    _meta['name'] = name
    _meta['symbol'] = symbol
    _meta['decimals'] = decimals
  end),

  name = typecheck('->', 'string')(function ()
    return _meta['name']
  end),

  symbol = typecheck('->', 'string')(function ()
    return _meta['symbol']
  end),

  decimals = typecheck('->', 'number')(function ()
    return _meta['decimals']
  end),
}) 

function constructor()
    Detailed.init("mytoken", "mt", 18)
    Mintable.init()
    Token.mint(system.getSender(), bignum.number("500000000000000000000000000"));
end

function totalSupply()
    return Token.totalSupply()
end

function balanceOf(addr_owner)
    return Token.balanceOf(addr_owner)
end
  
function allowance(addr_owner, addr_spender)
    return Token.allowance(addr_owner, addr_spender)
end 

function transfer(addr_to, big_value)
    return Token.transfer(addr_to, big_value)
end

function approve(addr_spender, big_value)
    return Token.approve(addr_spender, big_value)
end

function transferFrom(addr_from, addr_to, big_value)
    return Token.transferFrom(addr_from, addr_to, big_value)
end

function name()
    return Detailed.name()
end

function symbol()
    return Detailed.symbol()
end

function decimals()
    return Detailed.decimals()
end

function mint(addr_to, big_value)
    return Mintable.mint(addr_to, big_value)
end

abi.register(totalSupply, balanceOf, allowance, transfer, approve, transferFrom)
abi.register(name, symbol, decimals)
abi.register(mint)