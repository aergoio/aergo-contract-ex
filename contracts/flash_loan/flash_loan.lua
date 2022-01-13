state.var {
  loan_interest = state.value(),  -- number
  loan_shares = state.value(),    -- number
  depositors = state.map()
}

minimum_deposit_str = "1000000000000000000" -- 1 aergo

function constructor()
  loan_interest:set(0.001)  -- 0.1% - use 1 contract for each rate
  loan_shares:set(0)
end

function get_interest_rate()
  return loan_interest:get()
end

-- deposit funds to this contract to earn fees
function deposit()

  local address = system.getOrigin()
  local user = depositors[address]
  assert(user == nil, "you already have a participation. please remove and insert again")

  local amount_str = system.getAmount()
  local amount = bignum.number(amount_str)
  assert(bignum.compare(amount, 0) > 0, "you must send funds to be able to participate")

  local minimum_deposit = bignum.number(minimum_deposit_str)
  assert(bignum.compare(amount, minimum_deposit) >= 0, "the minimum deposit is 1 aergo")

  -- get the contract balance without the sent amount
  local balance = bignum.number(contract.balance()) - amount
  local total_shares = loan_shares:get()
  assert( bignum.iszero(balance) == (total_shares==0), "contract with invalid state")

  if bignum.iszero(balance) then
    user_shares = bignum.tonumber(amount / minimum_deposit)
  else
    user_shares = bignum.tonumber(total_shares * amount / balance)
  end

  -- save the number of shares from this user
  local user = {
    num_shares = user_shares,
    initial_amount = amount_str,
    start_time = system.getTimestamp()
  }

  -- save this participation
  depositors[address] = user

  -- update the total number of shares
  total_shares = total_shares + user_shares
  loan_shares:set(total_shares)

  -- return the share of the pool
  return user_shares / total_shares
end

-- withdraw funds from this contract
function withdraw()

  local address = system.getOrigin()
  local user = depositors[address]
  assert(user ~= nil, "no deposit found for this account")

  local balance = bignum.number(contract.balance())
  assert(bignum.compare(balance, 0) > 0, "no funds on this contract")

  local total_shares = loan_shares:get()
  assert(total_shares > 0, "no funds on this contract")

  local user_shares = user["num_shares"]
  assert(user_shares > 0, "this user has no shares")

  -- calculate the amount for this user
  local amount = balance * user_shares / total_shares

  -- send the funds to the investor
  contract.send(address, amount)

  -- delete its participation
  depositors:delete(address)

  -- update the total number of shares
  loan_shares:set(total_shares - user_shares)

end

function request_loan(amount, callback, args)

  if type(amount) ~= 'bignum' then
    amount = bignum.number(amount)
  end
  local balance_before = bignum.number(contract.balance())
  assert(bignum.compare(amount, balance_before) <= 0, "not enough funds for this loan")

  local interest_rate = loan_interest:get()
  local fee = multiply_by_decimal(amount, interest_rate)
  local amount_to_pay = amount + fee

  -- call the contract function with the requested funds
  contract.call.value(amount)(system.getSender(), callback, args, amount, amount_to_pay)

  local balance_after = bignum.number(contract.balance())
  local paid_fee = balance_after - balance_before

  assert(paid_fee >= fee, "you must pay back the loan with 0.1% interest")

end

function pay_loan()
  -- nothing here, just accept payment through this function
end

function get_investment_info(address)

  --local address = system.getOrigin()
  local user = depositors[address]
  assert(user ~= nil, "account not found")

  local balance_str = contract.balance()
  local balance = bignum.number(balance_str)
  assert(bignum.compare(balance, 0) > 0, "no funds on this contract")

  local total_shares = loan_shares:get()
  assert(total_shares > 0, "no funds on this contract")

  local user_shares = user["num_shares"]
  assert(user_shares > 0, "this user has no shares")

  local amount = balance * user_shares / total_shares

  local info = {
    pool_balance = balance_str,
    pool_share = user_shares / total_shares,
    start_time = user["start_time"],
    initial_amount = user["initial_amount"],
    current_amount = bignum.tostring(amount)
  }

  return json.encode(info)
end

function multiply_by_decimal(value, decimal)
  local denominator = 10000
  local numerator = decimal * denominator
  return value * numerator / denominator
end

abi.payable(deposit, pay_loan)
abi.register(request_loan, withdraw)
abi.register_view(get_interest_rate, get_investment_info)

--[[

Available Lua modules:
  string  math  table  bit

Available Aergo modules:
  system  contract  db  crypto  bignum  json

]]
