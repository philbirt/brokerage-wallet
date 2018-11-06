pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
/**
 * Sometimes it is useful for a contract to own tokens on behalf of users.
 */
contract BrokerageWallet is Ownable {
    using SafeMath for uint;

    /** Contract administrator */
    address public admin;

    /** The active signers */
    mapping(address => bool) public approvers;

    /** balance registry */
    /** tokenAddress => investorAddress => balance */
    mapping(address => mapping(address => uint256)) public ledger;

    /** logging deposit or their failure */
    event LogDeposit(address indexed _token, address indexed _investor, uint _amount);
    event LogDepositFail(address indexed _token, address indexed _investor, uint _amount);

    // ~~~~~~~~~~~~~~ //
    // Access control //
    // ~~~~~~~~~~~~~~ //

    modifier onlyApprover {
        require(approvers[msg.sender], "This action is only for approvers");
        _;
    }

    // ~~~~~~~~~~~~ //
    // End user API //
    // ~~~~~~~~~~~~ //

    function deposit(address _token, uint256 _amount) public {
        uint balance = ledger[_token][msg.sender];
        ledger[_token][msg.sender] = balance.add(_amount);

        ERC20 token = ERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);

        emit LogDeposit(_token, msg.sender, _amount);
    }

    // function offerTokens(address token, uint256 amount);
    // function transfer(address token, address src, address dst, uint256 amount);
    // function withdraw(address token, uint256 amount);

    // ~~~~~~~~~~~~~~ //
    // Administration //
    // ~~~~~~~~~~~~~~ //

    // function approveWithdrawals(uint256 begin, uint256 end) onlyApprover;
    function toggleApprover(address _approver) public onlyOwner {
        if (approvers[_approver]) {
            approvers[_approver] = false;
        } else {
            approvers[_approver] = true;
        }
    }
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
