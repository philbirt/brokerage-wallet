---
updated: 2018-11-08
---

A brokerage wallet
====

This software has two goals.  First, it should enable street name trading of
security tokens, where a brokerage owns tokens on behalf of users.  Second, it
should implement a hub and spoke payment channel system to minimize the need to
include transactions in the Ethereum blockchain during the normal course of
trading.

Specification
----

Tokens are owned by an orchestration contract which maintains an internal
ledger tracking the number of tokens being held in the name of each investor.
The system must implement three operations: 

- `deposit` - Here the user should first call `approve` on the underlying
  `ERC20` contract, then `deposit` to transfer the tokens. 
- `trade` - Transfer subtokens from one investor to another.  A transfer should
  require the source investor to first call `offerTokens` to mark a certain
  quantity of tokens for sale.  Then the platform operator calls `clearTrade`,
  passing in a reference to the earlier created sell, and the subtokens are
  transfered to the buyer.  (_Note: There must also be an `unOfferTokens`
  method._)
- `withdraw` - Transfer tokens to an external address.  This should be achieved
  in two steps.  First an investor should initiate a transfer.  Then transfer
  requests are approved by a list of approvers.  Once a threshold has been reached,
  the tokens are transfered to the owner.

### Roles & access control

- **The public.**  Any (whitelisted) account can deposit tokens, post them for sale, and
  withdraw tokens.
- **Platform.**  The platform account can execute transfers, and signs withdraw requests.
- **Administrator.**  The administrator can perform upgrades, set balances (for
  disaster recovery), and modify the approver list.
- **Approvers.**  The approvers can sign withdraw requests.

TODO
----

- [ ] discuss security failure scenarios per role and mitigations
