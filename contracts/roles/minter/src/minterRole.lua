import "aergo-contract-ex/typecheck"

state.var{
    _minter = state.map(), -- string -> boolean
}

minterInit = function ()
	_minter[system.getCreator()] = true
end

isMinter = typecheck('address', '->', 'boolean')(function (account)
	return _minter[account] or false
end)

onlyMinter = function() 
	assert(isMinter(system.getSender()), 'minter only')
end

addMinter =  typecheck('address', '->')(function (account) onlyMinter()
	_minter[account] = true
end)

renounceMinter = function() 
	_minter[system.getSender()] = false
end