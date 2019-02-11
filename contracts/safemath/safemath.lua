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