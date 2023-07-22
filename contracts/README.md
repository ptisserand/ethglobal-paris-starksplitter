# PaymentSplitter

This contract allows to split ERC20 payments among a group of accounts. 
The sender does not need to be aware
that the ERC20 will be split in this way, since it is handled transparently by the contract.

The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each account to a number of shares.

Of all the ERC20 that this contract receives, each account will then be able to claim an amount proportional to the percentage of total shares they were assigned.

`PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the `release` function.
