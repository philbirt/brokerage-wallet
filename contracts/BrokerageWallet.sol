pragma solidity ^0.4.25;

/**
 * Sometimes it is useful for a contract to own tokens on behalf of users.
 */
contract BrokerageWallet {

    /** Contract administrator */
    public address admin;

    /** The active signers */
    public mapping(address => bool) approvers;

    // ~~~~~~~~~~~~~~ //
    // Access control //
    // ~~~~~~~~~~~~~~ //

    modifier onlyApprover {
        require(approvers[msg.sender], "This action is only for approvers");
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "This action is only for the administrator");
        _;
    }

    // ~~~~~~~~~~~~ //
    // End user API //
    // ~~~~~~~~~~~~ //

    function deposit(address token, uint256 amount);
    function offerTokens(address token, uint256 amount);
    function transfer(address token, address src, address dst, uint256 amount);
    function withdraw(address token, uint256 amount);

    // ~~~~~~~~~~~~~~ //
    // Administration //
    // ~~~~~~~~~~~~~~ //

    function approveWithdrawals(uint256 begin, uint256 end) onlyApprover;
    function toggleSigner(address signer) onlyAdmin;
    function changeAdmin(address newAdmin) onlyAdmin;

}

// Questions 
// ----
// 
// There are two obvious approval models: (1) each approver can approve any
// withdrawal request, or (2) each approver can only approve withdrawal
// requests for its own particular subset of tokens.  Which of these (or both)
// should we implement?

// Payment channels
// ----
// 
// A future version of this contract should support payment channels, in a hub
// and spoke topology.
