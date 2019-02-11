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
