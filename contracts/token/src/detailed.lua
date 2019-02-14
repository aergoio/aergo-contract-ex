import "aergo-contract-ex/typecheck"
import "./token.lua"

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