# Flash Loans

Flash loans are loans in which we can borrow an amount of tokens without
any collateral and we must pay them back in the same transaction,
including the interest.

If the charged amount is not paid then the transaction is cancelled by
the contract.


## Tokens

This contract implements a flash loan for the Aergo token.

**TODO:** implement another contract for ARC1 tokens


## Participation

It is possible to participate in 2 ways:


### 1. Deposit and Earn

Supplying tokens to the loan pool to earn interest fees.

You can withdraw your tokens with the earned fees at any time.


### 2. Borrow

If you don't own tokens of interest then you can borrow them on the
flash loan contract.

You will need to implement a contract to request the loan, process it
on a callback function and pay it back.


## How to Use

Your contract should request a loan with a call like this:

```lua
contract.call(flash_loan, "request_loan", loan_amount, "process_loan", context)
```

Your contract must implement a callback function to receive and process the loan.
It must have 3 arguments: `context, loan_amount, amount_to_pay`

The first one is the value passed when requesting the loan. The other values are
filled by the loan contract, containing the loan amount and the amount that should
be paid until the end of the function call.

The payment should be done with a call like this:

```lua
contract.call.value(amount_to_pay)(flash_loan, "pay_loan")
```

You can protect your callback function from being called by others by using this
line:

```lua
assert(system.getSender() == flash_loan, "permission denied")
```

Check a simple example [here](caller.lua)
