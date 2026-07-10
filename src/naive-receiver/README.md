# Naive Receiver

There’s a pool with 1000 WETH in balance offering flash loans. It has a fixed fee of 1 WETH. The pool supports meta-transactions by integrating with a permissionless forwarder contract. 

这里存在一个余额为1000WETH的pool提供flash loan. 它收取固定1WETH费用. pool通过集成无许可转发合约从而支持meta-transaction.

A user deployed a sample contract with 10 WETH in balance. Looks like it can execute flash loans of WETH.

一个用户部署了一个带有10WETH余额的示例合约. 看起来这个合约可以执行WETH的flash loan.

All funds are at risk! Rescue all WETH from the user and the pool, and deposit it into the designated recovery account.

所有的资金都处于风险之中! 将所有的WETH从user和pool中拯救出来, 并将其存入指定的recovery account.
