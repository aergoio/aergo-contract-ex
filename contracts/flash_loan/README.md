# Flash Loans

Flash loans are loans in which we can borrow an amount of tokens without
any collateral and we must pay them back in the same transaction,
including the interest.

If the charged amount is not paid then the transaction is cancelled by
the contract.


## Tokens

This contract implements a flash loan for the Aergo token.

**TODO:** implement another contract for ARC1 tokens


## Using it

It is possible to participate in 2 ways:


### 1. Deposit and Earn

Supplying tokens to the loan pool to earn interest fees.

You can withdraw your tokens with the earned fees at any time.


### 2. Borrow

If you don't own tokens of interest then you can borrow them on the
flash loan contract.

You will need to implement a contract to request the loan, process it
on a callback function and pay it back. Check a simple example [here](caller.lua)
