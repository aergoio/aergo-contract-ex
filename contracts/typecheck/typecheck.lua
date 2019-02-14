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