-- from http://lua-users.org/wiki/LuaTypeChecking
--
-- Type check function that decorates functions.
-- supported type: string, number, function, boolean, nil, userdata, address, bignum
-- Example:
--   sum = typecheck('number', 'number', '->', 'number')(
--     function(x, y) return x + y end
--   )

function typecheck(...)
  
end

local function printMe(string__good, number__bad) 
  typecheck(string__good, number__bad) 
     print(debug.getlocal(1, 0))
end

print(printMe(1,2))
