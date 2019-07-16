function constructor()
    testall()
end

function testall()
    systest()
    arraytest()
    maptest()
    valuetest()
    gettest()
end

function systest()
    id = 'getSender'; system.setItem(id, system.getSender())
    system.print(id, system.getItem(id))
    id = 'getBlockheight'; system.setItem(id, system.getBlockheight())
    system.print(id, system.getItem(id))
    id = 'getTxhash'; system.setItem(id, system.getTxhash())
    system.print(id, system.getItem(id))
    id = 'getTimestamp'; system.setItem(id, system.getTimestamp())
    system.print(id, system.getItem(id))
    id = 'getContractID'; system.setItem(id, system.getContractID())
    system.print(id, system.getItem(id))
    id = 'getAmount'; system.setItem(id, system.getAmount())
    system.print(id, system.getItem(id))
    id = 'getCreator'; system.setItem(id, system.getCreator())
    system.print(id, system.getItem(id))
    id = 'getOrigin'; system.setItem(id, system.getOrigin())
    system.print(id, system.getItem(id))
    id = 'getPrevBlockHash'; system.setItem(id, system.getPrevBlockHash())
    system.print(id, system.getItem(id))
    id = 'random'; system.setItem(id, system.random(10000))
    system.print(id, system.getItem(id))
    id = 'time'; system.setItem(id, system.time())
    system.print(id, system.getItem(id))
    id = 'difftime'; system.setItem(id, system.difftime(system.time()))
    system.print(id, system.getItem(id))
    id = 'date'; system.setItem(id, system.date())
    system.print(id, system.getItem(id))
end

function arraytest()
    state.var {
        Array = state.array(999999999)
      }
    id = 'a11'; system.setItem(id, {pcall(function() Array[1] = 1 end)})
    system.print(id, system.getItem(id), Array[1])
    id = 'a12'; system.setItem(id, {pcall(function() Array[2] = 'str' end)})
    system.print(id, system.getItem(id), Array[2])
    id = 'a13'; system.setItem(id, {pcall(function() Array[3] = {1, a='tb', b=3, 4, 5} end)})
    system.print(id, system.getItem(id), Array[3])
    id = 'a14'; system.setItem(id, {pcall(function() Array[4] = 'str' end)})
    system.print(id, system.getItem(id), Array[4])
    id = 'a15'; system.setItem(id, {pcall(function() Array[5] = {'tb', 3} end)})
    system.print(id, system.getItem(id), Array[5])
    id = 'a21'; system.setItem(id, {pcall(function() Array['str'] = 1 end)})
    system.print(id, system.getItem(id))
    id = 'a22'; system.setItem(id, {pcall(function() Array[6] = 1 end)})
    system.print(id, system.getItem(id), Array[6])
    id = 'a23'; system.setItem(id, {pcall(function() Array[-1] = 1 end)})
    system.print(id, system.getItem(id))
    id = 'a24'; system.setItem(id, {pcall(function() Array[0] = 1 end)})
    system.print(id, system.getItem(id))
    id = 'a25'; system.setItem(id, {pcall(function() Array[9999999999999999999999999999999999999999999999999999999999999999999999] = 1 end)})
    system.print(id, system.getItem(id))
    id = 'a26'; system.setItem(id, {pcall(function() Array[999999999] = 1 end)})
    system.print(id, system.getItem(id))
    id = 'a27'; system.setItem(id, {pcall(function() Array[nil] = 1 end)})
    system.print(id, system.getItem(id))
    id = 'a28'; system.setItem(id, Array:length())
    system.print(id, system.getItem(id))

    id = 'a31'; system.setItem(id, {pcall(function() Array[4] = {nil} end)})
    system.print(id, system.getItem(id), Array[4])

    id = 'a41'; system.setItem(id, {pcall(function() Array[5] = bignum.number('9999999999999999999999999999') end)})
    system.print(id, system.getItem(id), Array[5])
end

function maptest()

    state.var {
        Map = state.map(),
        BigMap = state.map()
    }

    id = 'm11'; system.setItem(id, {pcall(function() Map[id] = 1 end)})
    system.print(id, Map[id])
    id = 'm12'; system.setItem('m12', {pcall(function() Map[id] = 'ppppppppppppppppppppppp' end)})
    system.print(id, Map[id])
    id = 'm13'; system.setItem('m13', {pcall(function() Map[id] = {0, 'x', 'y', 'z', {'1', '2', bignum.number('999999999999999999999999999')}} end)})
    system.print(id, Map[id])
    id = 'm14'; system.setItem('m14', {pcall(function() Map[id] = {a=1, b=2, c='x'} end)})
    system.print(id, Map[id])
    id = 'm15'; system.setItem('m15', {pcall(function() Map[id] = bignum.number('-99999999999999999999999999') end)})
    system.print(id, Map[id])
    id = 'm16'; system.setItem('m16', {pcall(function() Map[id] = json.decode('{"str":"stringval1", "arr":[1,2,3, "string"], "num": 0, "map":{"v1":1, "v2":2}, 999:1, "big1": 82758297529857298472984720780970273047, {"_bignum": "2124234234"}}') end)})
    system.print(id, Map[id])

    id = 'm21'; system.setItem(id, {pcall(function() Map[9999999] = 1 end)})
    system.print(id, Map[id])
    id = 'm22'; system.setItem(id, {pcall(function() Map[nil] = 1 end)})
    system.print(id, Map[id])
    id = 'm23'; system.setItem(id, {pcall(function() Map[id] = nil end)})
    system.print(id, Map[id])

    local rndTable = {};

    for i=1, 4156 do
        table.insert(rndTable, system.random(100000000000000))
    end

    i = 0
    for key, value in pairs(rndTable) do
        i = i + 1
        BigMap[i] = value
        system.print(i, BigMap[i])
    end

end

function valuetest()
    state.var {
        Value1 = state.value(),
        Value2 = state.value(),
        Value3 = state.value(),
        Value4 = state.value(),
        Value5 = state.value()
    }

    id = 'v11'; system.setItem(id, {pcall(function() Value1:set(1) end)})
    system.print(id, system.getItem(id), Value1:get())
    id = 'v12'; system.setItem('v12', {pcall(function() Value2:set('1') end)})
    system.print(id, system.getItem(id), Value2:get())
    id = 'v13'; system.setItem('v13', {pcall(function() Value3:set({a=1, b=2, c='x'}) end)})
    system.print(id, system.getItem(id), Value3:get())
    id = 'v14'; system.setItem('v14', {pcall(function() Value4:set(bignum.number('9999999999999999999999999999999999999999999999'))  end)})
    system.print(id, system.getItem(id), Value4:get())
    id = 'v15'; system.setItem('v15', {pcall(function() Value5:set(json.decode('{"str":"stringval1", "arr":[1,2,3, "string"], "num": 0, "map":{"v1":1, "v2":2}, 999:1, "big1": 82758297529857298472984720780970273047, {"_bignum": "2124234234"}}')) end)})
    system.print(id, system.getItem(id), Value5:get())
    id = 'v16'; system.setItem('v16', '한글')
    system.print(id, system.getItem(id))
    id = 'v17'; system.setItem('v17', 'special char $#!@ §▼≒Ψ')
    system.print(id, system.getItem(id))
    id = 'v18'; system.setItem('v18', nil)
    system.print(id, system.getItem(id))

end

function gettest()
    system.setItem('get11', {system.getItem('getCreator'), system.getCreator()})
    system.setItem('get12', {system.getItem('getContractID'), system.getContractID()})
    system.setItem('get13', {system.getItem('getTimestamp'), system.getTimestamp()}) -- is this return last tx time?
    system.setItem('get14', {system.getItem('getBlockheight'), system.getBlockheight()})
end

abi.register(testall)
