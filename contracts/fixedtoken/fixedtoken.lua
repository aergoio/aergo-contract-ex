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

------------------------------------------------------------------------------
-- FixedSupplyToken
-- @see https://theethereum.wiki/w/index.php/ERC20_Token_Standard
------------------------------------------------------------------------------

state.var {
    Symbol = state.value(),
    Name = state.value(),
    TotalSupply = state.value(),
    Book = state.map(),
    ApproveBook = state.map()
}

function constructor() 
    Symbol:set("FIXED")
    Name:set("Example Fixed Supply Token")
  
    local total = bignum.number("5000000000000000000")

    TotalSupply:set(total)
    Book[system.getCreator()] = total
    Book[address.nilAddress()] = bignum.number(0)

    system.print("create fixed token successfully. owner: " .. system.getCreator())
end

---------------------------------------
-- Get a total token supply.
-- @type query
-- @param id Session identification.
-- @return  total supply of this token
---------------------------------------
function totalSupply()
    return safemath.sub(TotalSupply:get(), Book[address.nilAddress()])
end

---------------------------------------
-- Get a balance of an owner.
-- @type    query
-- @param   owner a target address
-- @return  balance of owner
---------------------------------------
function balanceOf(owner)
    assert(address.isValidAddress(owner), "[balanceOf] invalid address format: " .. owner)
    
    return Book[owner] or bignum.number(0)
end

---------------------------------------
-- Transfer sender's token to target 'to'
-- @type call
-- @param to    a target address
-- @param value an amount of token to send
---------------------------------------
function transfer(to, value) 
    local from = system.getSender()
    
    local bvalue = bignum.number(value)

    assert(bvalue > bignum.number(0), "[transfer] invalid value")
    assert(address.isValidAddress(to), "[transfer] invalid address format: " .. to)
    assert(to ~= from, "[transfer] same sender and receiver")
    assert(Book[from] and bvalue <= Book[from], "[transfer] not enough balance")
  
    Book[from] = safemath.sub(Book[from], bvalue)
    Book[to] = safemath.add(Book[to], bvalue)

    -- TODO event notification
    system.print(string.format("transfer %s -> %s: %s", from, to, value))
end

local function approveKeyGen(requester, spender) 
    return requester .. "->" .. spender
end

---------------------------------------
-- Allow spender to use this amount of value of token
-- @type call
-- @param spender   a spender's address
-- @param value     an amount of token to approve
---------------------------------------
function approve(spender, value) 
    local bvalue = bignum.number(value)

    assert(bvalue > bignum.number(0), "[approve] invalid value")
    assert(address.isValidAddress(spender), "[approve] invalid address format: " .. spender)

    local key = approveKeyGen(system.getSender(), spender)
  
    ApproveBook[key] = bvalue
  
    -- TODO event notification
    system.print(string.format("approve %s: %s", key, bvalue))
end


---------------------------------------
-- Transfer 'from's token to target 'to'. 
-- A this function sender have to be approved to spend the amount of value from 'from'
-- @type call
-- @param from  a sender's address
-- @param to    a receiver's address
-- @param value an amount of token to send
---------------------------------------
function transferFrom(from, to, value)
    local bvalue = bignum.number(value)

    assert(bvalue > bignum.number(0), "[transferFrom] invalid value")
    assert(address.isValidAddress(from), "[transferFrom] invalid address format: " .. from)
    assert(address.isValidAddress(to), "[transferFrom] invalid address format: " .. to)
    assert(Book[from] and bvalue <= Book[from], "[transferFrom] not enough balance")
  
    local allowedToken = allowance(from, system.getSender())
    assert(bvalue <= allowedToken, "[transferFrom] not enough allowed balance")

    Book[from] = safemath.sub(Book[from], bvalue)
    Book[to] = safemath.add(Book[to], bvalue)
  
    local key = approveKeyGen(from, system.getSender())

    ApproveBook[key] = safemath.sub(allowedToken - bvalue)
end

---------------------------------------
-- Get an amount of allowance from owner to spender
-- @type query
-- @param owner     owner address
-- @param spender   allowed address
-- @return          amount of approved balance between 2 addresses
---------------------------------------
function allowance(owner, spender)
    assert(address.isValidAddress(owner), "[allowance] invalid address format: " .. owner)
    assert(address.isValidAddress(spender), "[allowance] invalid address format: " .. spender)
  
    local key = approveKeyGen(owner, spender)
  
    return ApproveBook[key] or bignum.number(0)
end

---------------------------------------
-- Allow use of balance to another
-- @type    call
-- @param   spender a contract address to call internally and spend balance
-- @param   value   amount of balance to approve for the spender
-- @param   ...     parameters to pass the spender contract
---------------------------------------
function approveAndCall(spender, value, ...)
    local bvalue = bignum.number(value)
    local sender = system.getSender()

    assert(address.isValidAddress(spender), "[approveAndCall] invalid address format: " .. spender)

    local key = approveKeyGen(sender, spender)
  
    ApproveBook[key] = bvalue
  
    contract.call(spender, "receiveApproval", sender, bvalue, ...)

    -- TODO event notification
    system.print(string.format("approveAndCall, approve %s: %s, call: %s", key, bvalue, spender))
end 

-- register functions to abi
abi.register(totalSupply, transfer, balanceOf, approve, allowance, transferFrom)
abi.payable(approveAndCall)