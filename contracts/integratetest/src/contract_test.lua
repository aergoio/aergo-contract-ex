function constructor()
  -- need at least 3 aergo to test
  assert(tonumber(system.getAmount()) >= 3000000000000000000, 'need at least 3000000000000000000 aer '..system.getAmount())
  system.print('deploy', system.getAmount())
  testall()
end

function testall()
  deploytest()
  sendtest()
  calltest()
  balancetest()
  eventtest()
end

function deploytest()
  src = [[
  function default()
    contract.send(system.getSender(), system.getAmount())
  end

  function getargs(...)
    tb = {...}
  end

  abi.payable(default)
  abi.register(getargs)
  ]]

  addr = contract.deploy(src)
  id = 'deploy_src'; system.setItem(id, addr)
  system.print(id, system.getItem(id))

  incorrect_src = [[
  invalid contract definition code
  ]]

  id = 'deploy_invalid_src'; system.setItem(id, {pcall(function() contract.deploy(incorrect_src) end)})
  system.print(id, system.getItem(id))

  korean_char_src = [[
  function 함수()
    변수 = 1
    결과 = 변수 + 3
    system.print('결과', 결과)
  end

  abi.register(함수)
  ]]

  
  korean_char_src222 = [[
    function default()
      contract.send(system.getSender(), system.getAmount())
    end
  
    function getargs(...)
      tb = {...}
    end
  
    function x()
    end

    abi.payable(default)
    abi.register(getargs)
  ]]

  korean_addr =  contract.deploy(korean_char_src)
  id = 'korean_char_src'; system.setItem(id, korean_addr)
  system.print(id, system.getItem(id))

  id = 'korean01'; system.setItem(id, {pcall(function() contract.call(korean_addr, '함수') end)})
  system.print(id, system.getItem(id))

end

function sendtest()
  addr = system.getItem("deploy_src")
  system.print('ADDRESS', addr, system.getAmount())
  
  id = 's01'; system.setItem(id,{pcall(function() contract.send(addr, system.getAmount()) end)})
  system.print(id, system.getItem(id))
  id = 's02'; system.setItem(id,{pcall(function() contract.send(addr, bignum.number(system.getAmount()) + bignum.number(1)) end)})
  system.print(id, system.getItem(id))

  id = 's11'; system.setItem(id, {pcall(function() contract.send(addr, '1 aergo') end)})
  system.print(id, system.getItem(id))
  id = 's12'; system.setItem(id, {pcall(function() contract.send(addr, '-1 aergo') end)})
  system.print(id, system.getItem(id))
  id = 's13'; system.setItem(id, {pcall(function() contract.send(addr, '0 aer') end)})
  system.print(id, system.getItem(id))
  id = 's14'; system.setItem(id, {pcall(function() contract.send(addr, 'many aergo') end)})
  system.print(id, system.getItem(id))

  id = 's21'; system.setItem(id,{pcall(function() contract.send(addr, 10000) end)})
  system.print(id, system.getItem(id))
  id = 's22'; system.setItem(id,{pcall(function() contract.send(addr, -1) end)})
  system.print(id, system.getItem(id))
  id = 's23'; system.setItem(id,{pcall(function() contract.send(addr, 0) end)})
  system.print(id, system.getItem(id))
  id = 's24'; system.setItem(id,{pcall(function() contract.send(addr, nil) end)})
  system.print(id, system.getItem(id))

  id = 's31'; system.setItem(id,{pcall(function() contract.send(addr, bignum.number("100000")) end)})
  system.print(id, system.getItem(id))
  id = 's32'; system.setItem(id,{pcall(function() contract.send(addr, bignum.number("0")) end)})
  system.print(id, system.getItem(id))
  id = 's33'; system.setItem(id,{pcall(function() contract.send(addr, bignum.number("-1")) end)})
  system.print(id, system.getItem(id))
  id = 's34'; system.setItem(id,{pcall(function() contract.send(addr, bignum.number(nil)) end)})
  system.print(id, system.getItem(id))
end

function calltest()
  addr = system.getItem("deploy_src")
  id = 'c01';  system.setItem(id,{pcall(function() contract.call(addr, 'non_exist_func_will_call_default', 'args1') end)})
  system.print(id, system.getItem(id))

  tb = {}
  for i = 1, 7999 do
    table.insert(tb, i)
  end

  for i = 1, 122 do
    contract.call(addr, 'getargs', unpack(tb))
  end

end

function balancetest()
  system.print("b01", contract.balance())
end

function eventtest()
  contract.event('eventCall', 0, 1, 3485274927842984294248762957, 'str', bignum.number("99999999999999"))
  contract.event('한글', nil, 0, 'good')
  contract.event('!@#')
end

function default()
  -- do nothing
end

abi.payable(constructor, default)
abi.register(testall)

--deploy a1 10 c1 .\contract_test.lua
