--- a simple safe math library
-- @see https://github.com/bokkypoobah/Tokens/blob/master/contracts/SafeMth.sol
-- @module safemath

safemath = {}

-- big number api
function safemath.add(a, b) 
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)

  local c = a + b
  assert(c >= a)
  
  return c
end

function safemath.sub(a, b) 
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)

  assert(b <= a, "first value must be bigger than second")
  local c = a - b

  return c
end

function safemath.mul(a, b) 
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)
  
  local c = a * b
  assert(a == 0 or c/a == b, "overflow")
  
  return c
end

function safemath.div(a, b)
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)
  
  assert(b > 0, "divide by zero")
  c = a / b

  return c
end  

function safemath.mod(a, b)
  a = bignum.number(a or 0)
  b = bignum.number(b or 0)
  
  assert(b ~= 0, "divide by zero")
  c = a % b

  return c
end