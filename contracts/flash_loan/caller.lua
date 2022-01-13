
flash_loan = "AmgHb8aa81MzQpjqPrt9kfeYrrDkaEgtuDumJVVL4y3q41DaaFrx"
loan_fee = 0.001

-- oportunity = ""

function use_flash_loan(amount, oportunity_gain)

  amount = bignum.number(amount)

  -- multiply by 1 aergo
  local loan_amount = amount * 1000000000000000000

  contract.call(flash_loan, "request_loan", loan_amount, "process_loan", oportunity_gain)

end

function process_loan(args, loan_amount, amount_to_pay)

  -- only the flash loan contract can call this function
  assert(system.getSender() == flash_loan, "permission denied")

  -- local amount = bignum.number(system.getAmount())
  assert(bignum.compare(loan_amount, 0) > 0, "no loan received")

  --local amount_to_pay = amount + amount * loan_fee

  -- here the contract should process some oportunity that returns more than the sent amount
  -- contract.call.value(amount)(oportunity, "do_something", "...")

  -- for testing, lets use the contract funds
  -- lets say we've got 2% return on this fake oportunity
  --local returned_amount = multiply_by_decimal(loan_amount, 1.02)
  local oportunity_gain = args
  local returned_amount = multiply_by_decimal(loan_amount, oportunity_gain)

  assert(bignum.compare(returned_amount,amount_to_pay) > 0, "no profits -" ..
    " returned_amount: " .. bignum.tostring(returned_amount) .. 
    " loan_amount: " .. bignum.tostring(loan_amount) .. 
    " amount_to_pay: " .. bignum.tostring(amount_to_pay))

  -- contract.send(flash_loan, amount_to_pay)  -- requires a 'default' function on the receiving contract
  contract.call.value(amount_to_pay)(flash_loan, "pay_loan")

end

function multiply_by_decimal(value, decimal)
  local denominator = 10000
  local numerator = decimal * denominator
  return value * numerator / denominator
end

function transfer()
  -- nothing here, just to accept funds
end

abi.payable(transfer, process_loan)
abi.register(use_flash_loan)

--[[

Available Lua modules:
  string  math  table  bit

Available Aergo modules:
  system  contract  db  crypto  bignum  json

]]
