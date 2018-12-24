---------------------------------------
-- an utility function to represent behavior of class
-- @param   ... list of a table, which has field list, and objects to inheritent
-- @return      new object
---------------------------------------
function Object(...)
  local obj = {}
  
  -- copy all of parents and fields
  for i, parent in pairs({...}) do 
    for k, v in pairs(parent) do
      if(k ~= '__index') then 
        obj[k] = v         
      end
    end
  end
  
  -- set parent's meta
  obj.__index = obj 
  
  return obj
end