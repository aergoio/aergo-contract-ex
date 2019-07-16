function constructor()
  testall()
end

function testall()
  jsontest()
  cryptotest()
  bignumtest()
end

function jsontest()
  -- encode(arg)
  -- decode(string)

  tb = {}
  for i = 1, 100 do
    table.insert(tb, i)
  end

  json_obj = json.encode(tb)

  id = 'j01'; system.setItem(id, json_obj)
  system.print(id, system.getItem(id))

  id = 'j02'; system.setItem(id,json.decode(json_obj))
  system.print(id, system.getItem(id))

  id = 'j03'; system.setItem(id, {pcall(function() return json.encode({a = 'str', b = 2342, c = '@$%', d = '\n'}) end)})
  system.print(id, system.getItem(id))

  id = 'j04'; system.setItem(id, {pcall(function() return json.encode(nil) end)})
  system.print(id, system.getItem(id))
end

function cryptotest()
  -- crypto.sha256(arg)
  -- crypto.ecverify(message, signature, address)

    msg = crypto.sha256('string to hash')
    id = 'c01'; system.setItem(id, crypto.ecverify(msg, '0x30450221009149a8182add157596432f86977bd74dbe49d53dc2b4d7dcfc470fc735fea3cb02206d73838ab342a718553d43be070083492050ce6128132386be782f28e90cffef', 'AmPbWrQbtQrCaJqLWdMtfk2KiN83m2HFpBbQQSTxqqchVv58o82i'))
    system.print(id, system.getItem(id))

    id = 'c02'; system.setItem(id, {pcall(function() return crypto.ecverify(msg, nil, 'AmPbWrQbtQrCaJqLWdMtfk2KiN83m2HFpBbQQSTxqqchVv58o82i') end)})
    system.print(id, system.getItem(id))

    id = 'c03'; system.setItem(id, {pcall(function() return crypto.ecverify(msg, 'invaid sig', 'AmPbWrQbtQrCaJqLWdMtfk2KiN83m2HFpBbQQSTxqqchVv58o82i') end)})
    system.print(id, system.getItem(id))

    id = 'c04'; system.setItem(id, {pcall(function() return crypto.ecverify(msg, '0x00000000000000000001', 'AmPbWrQbtQrCaJqLWdMtfk2KiN83m2HFpBbQQSTxqqchVv58o82i') end)})
    system.print(id, system.getItem(id))

    id = 'c05'; system.setItem(id, {pcall(function() return crypto.ecverify(msg, '0x30450221009149a8182add157596432f86977bd74dbe49d53dc2b4d7dcfc470fc735fea3cb02206d73838ab342a718553d43be070083492050ce6128132386be782f28e90cffef') end)})
    system.print(id, system.getItem(id))

    id = 'c06'; system.setItem(id, {pcall(function() return crypto.ecverify(msg, '0x30450221009149a8182add157596432f86977bd74dbe49d53dc2b4d7dcfc470fc735fea3cb02206d73838ab342a718553d43be070083492050ce6128132386be782f28e90cffef', 'invalid addr') end)})
    system.print(id, system.getItem(id))

    system.setItem('c07', {pcall(function() return crypto.ecverify('0x1111', '0x30450221009149a8182add157596432f86977bd74dbe49d53dc2b4d7dcfc470fc735fea3cb02206d73838ab342a718553d43be070083492050ce6128132386be782f28e90cffef', 'AmPbWrQbtQrCaJqLWdMtfk2KiN83m2HFpBbQQSTxqqchVv58o82i') end)})
    system.print(id, system.getItem(id))
end

function bignumtest()
  -- bignum.number(x)
  id = 'b01'; system.setItem(id, {pcall(function() return bignum.number('999999999999999999999999999999999999999') end)})
  system.print(id, system.getItem(id))

  id = 'b02'; system.setItem(id, {pcall(function() return bignum.number('-999999999999999999999999999999999999999') end)})
  system.print(id, system.getItem(id))

  id = 'b03'; system.setItem(id, {pcall(function() return bignum.number(nil) end)})
  system.print(id, system.getItem(id))

  id = 'b04'; system.setItem(id, {pcall(function() return bignum.number(999999999999999999999999999999999999999) end)})
  system.print(id, system.getItem(id))

  id = 'b05'; system.setItem(id, {pcall(function() return bignum.number(-999999999999999999999999999999999999999) end)})
  system.print(id, system.getItem(id))

  id = 'b06'; system.setItem(id, {pcall(function() return bignum.number(10/3) end)})
  system.print(id, system.getItem(id))

  id = 'b07'; system.setItem(id, {pcall(function() return bignum.number('99.01') end)})
  system.print(id, system.getItem(id))

  id = 'b08'; system.setItem(id, {pcall(function() return bignum.number(999999999999^9) end)})
  system.print(id, system.getItem(id))

  id = 'b09'; system.setItem(id, {pcall(function() return bignum.number('123 aergo') end)})
  system.print(id, system.getItem(id))

  -- bignum.isneg(x)
  id = 'b10'; system.setItem(id, {pcall(function() return bignum.isneg('123') end)})
  system.print(id, system.getItem(id))

  id = 'b11'; system.setItem(id, {pcall(function() return bignum.isneg('-123') end)})
  system.print(id, system.getItem(id))

  id = 'b12'; system.setItem(id, {pcall(function() return bignum.isneg('-invalid num') end)})
  system.print(id, system.getItem(id))

  -- bignum.iszero(x)
  id = 'b21'; system.setItem(id, {pcall(function() return bignum.iszero(nil) end)})
  system.print(id, system.getItem(id))

  id = 'b22'; system.setItem(id, {pcall(function() return bignum.iszero(0000) end)})
  system.print(id, system.getItem(id))

  id = 'b23'; system.setItem(id, {pcall(function() return bignum.iszero('0000') end)})
  system.print(id, system.getItem(id))

  id = 'b24'; system.setItem(id, {pcall(function() return bignum.iszero('zero') end)})
  system.print(id, system.getItem(id))

  id = 'b25'; system.setItem(id, {pcall(function() return bignum.iszero(bignum.number(0)) end)})
  system.print(id, system.getItem(id))

  -- bignum.tonumber(x)
  id = 'b31'; system.setItem(id, {pcall(function() return bignum.tonumber(bignum.number(0)) end)})
  system.print(id, system.getItem(id))

  id = 'b32'; system.setItem(id, {pcall(function() return bignum.tonumber(nil) end)})
  system.print(id, system.getItem(id))

  id = 'b33'; system.setItem(id, {pcall(function() return bignum.tonumber(12345) end)})
  system.print(id, system.getItem(id))

  id = 'b34'; system.setItem(id, {pcall(function() return bignum.tonumber('12345') end)})
  system.print(id, system.getItem(id))

  -- bignum.neg(x)  (same as -x)
  id = 'b41'; system.setItem(id, {pcall(function() return bignum.neg('1234545364858373') end)})
  system.print(id, system.getItem(id))

  id = 'b42'; system.setItem(id, {pcall(function() return bignum.neg(23634) end)})
  system.print(id, system.getItem(id))

  id = 'b43'; system.setItem(id, {pcall(function() return bignum.neg(0) end)})
  system.print(id, system.getItem(id))

  id = 'b44'; system.setItem(id, {pcall(function() return bignum.neg('0') end)})
  system.print(id, system.getItem(id))

  id = 'b45'; system.setItem(id, {pcall(function() return bignum.neg('-100') end)})
  system.print(id, system.getItem(id))

  -- bignum.sqrt(x)
  id = 'b51'; system.setItem(id, {pcall(function() return bignum.sqrt('1000000000000000000') end)})
  system.print(id, system.getItem(id))

  id = 'b52'; system.setItem(id, {pcall(function() return bignum.sqrt('99999999') end)})
  system.print(id, system.getItem(id))

  id = 'b53'; system.setItem(id, {pcall(function() return bignum.sqrt('this is string') end)})
  system.print(id, system.getItem(id))

  id = 'b54'; system.setItem(id, {pcall(function() return bignum.sqrt('0') end)})
  system.print(id, system.getItem(id))

  id = 'b55'; system.setItem(id, {pcall(function() return bignum.sqrt('100000000000000000000000000000000') end)})
  system.print(id, system.getItem(id))

  id = 'b56'; system.setItem(id, {pcall(function() return bignum.sqrt(bignum.number('100000000000000000000000000000000')^bignum.number('1000000000000')) end)})
  system.print(id, system.getItem(id))

  id = 'b57'; system.setItem(id, {pcall(function() return bignum.sqrt('999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999') end)})
  system.print(id, system.getItem(id))

  id = 'b58'; system.setItem(id, {pcall(function() return bignum.sqrt('-100') end)})
  system.print(id, system.getItem(id))

  -- bignum.add(x, y) (same as x + y)
  -- bignum.sub(x, y) (same as x - y)
  -- bignum.mul(x, y) (same as x * y)
  -- bignum.mod(x, y) (same as x % y)
  -- bignum.div(x, y) (same as x / y)
  -- bignum.pow(x, y) (same as x ^ y)
  -- bignum.divmod(x, y)
  -- bignum.compare(x, y)
  -- bignum.powmod(x, y, m)
  function compute(a, b)
    rnd = system.random(100)
    -- system.print('rnd', a,b, rnd)
    return bignum.add(a, b), bignum.number(a + b), bignum.sub(a, b), bignum.number(a - b),
      bignum.mul(a, b), bignum.number(a * b), bignum.mod(a, b), bignum.number(a % b),
      bignum.div(a, b), bignum.number(a / b), bignum.pow(a, b), bignum.number(a ^ b),
      bignum.divmod(a, b), bignum.compare(a, b), bignum.powmod(a, b, rnd)
  end

  id = 'b61'; system.setItem(id, {pcall(function() return compute(1, 2) end)})
  system.print(id, system.getItem(id))

  id = 'b62'; system.setItem(id, {pcall(function() return compute(100, -200) end)})
  system.print(id, system.getItem(id))

  id = 'b63'; system.setItem(id, {pcall(function() return compute(-200, 300) end)})
  system.print(id, system.getItem(id))

  id = 'b64'; system.setItem(id, {pcall(function() return compute(bignum.number('99999999999999999999999999999'), bignum.number(991)) end)})
  system.print(id, system.getItem(id))

  id = 'b65'; system.setItem(id, {pcall(function() return compute(bignum.number('99'), '1') end)})
  system.print(id, system.getItem(id))

  id = 'b66'; system.setItem(id, {pcall(function() return compute(bignum.number('-99'), bignum.number('9')) end)})
  system.print(id, system.getItem(id))

  id = 'b67'; system.setItem(id, {pcall(function() return compute(bignum.number('99'), '-999') end)})
  system.print(id, system.getItem(id))

  id = 'b68'; system.setItem(id, {pcall(function() return compute(bignum.number('0'), '-999') end)})
  system.print(id, system.getItem(id))

  id = 'b69'; system.setItem(id, {pcall(function() return compute(bignum.number('999'), '0') end)})
  system.print(id, system.getItem(id))
end

abi.register(testall)
