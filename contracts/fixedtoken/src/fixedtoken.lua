import "aergo-contract-ex/safemath"
import "aergo-contract-ex/address"

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