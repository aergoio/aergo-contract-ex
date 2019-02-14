import "../src/detailed.lua"
import "../src/mintable.lua"
import "../src/token.lua"

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