import "aergo-contract-ex/typecheck"
import "aergo-contract-ex/roles/minter"
import "./token.lua"

Mintable = Object(Token, {
  init = function()
    minterInit()
  end,

  mint = typecheck('address', 'bignum', '->', 'boolean')(function(to, value) onlyMinter()
    Token.mint(to, value)
    return true
  end) 
})