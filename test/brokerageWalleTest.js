const truffleAssert = require('truffle-assertions');
const BrokerageWalletContract = artifacts.require("BrokerageWallet");

contract("BrokerageWallet", (accounts) => {
  beforeEach(async function() {
    this.brokerageWalletContract = await BrokerageWalletContract.deployed();
    this.erc20TokenAddress = "0xeee3598e2c3108c331c712ab4ce614f408f02538";
  });

  describe("deposit(address _token, uint256 _amount)", ()=>{
    beforeEach(async function() {
      this.depositAmount = 100;
    });

    it("credit the investors balance for the token", async function () {
      await this.brokerageWalletContract.deposit(this.erc20TokenAddress, this.depositAmount, { from: accounts[0] });

      const tokenUserBalance = await this.brokerageWalletContract.ledger(
        this.erc20TokenAddress,
        accounts[0],
      );

      assert.equal(tokenUserBalance.toNumber(), this.depositAmount);
    });

    it("emits a LogDeposit event", async function () {
      await this.brokerageWalletContract.deposit(this.erc20TokenAddress, this.depositAmount).then(async (result) => {
        truffleAssert.eventEmitted(result, 'LogDeposit', (ev) => {
          return ev._token === this.erc20TokenAddress && ev._investor === accounts[0] && ev._amount.toNumber() === this.depositAmount;
        });
      });
    });
  });

  describe("toggleApprover(address _approver)", () => {
    it("adds approver if not currently in the mapping", async function () {
      const emptyApprover = await this.brokerageWalletContract.approvers(accounts[1]);
      assert.equal(emptyApprover, false);

      await this.brokerageWalletContract.toggleApprover(accounts[1]);
      const newApprover = await this.brokerageWalletContract.approvers(accounts[1]);
      assert.equal(newApprover, true);
    });

    it("removes approver if its already in the mapping", async function () {
      const emptyApprover = await this.brokerageWalletContract.approvers(accounts[1]);
      assert.equal(emptyApprover, true);

      await this.brokerageWalletContract.toggleApprover(accounts[1]);
      const newApprover = await this.brokerageWalletContract.approvers(accounts[1]);
      assert.equal(newApprover, false);
    });

    context("when called by non-owner", async function () {
      it("raises an exception and does not toggle the approver", async function () {
        await truffleAssert.fails(
          this.brokerageWalletContract.toggleApprover.call(accounts[1], { from: accounts[1] })
        );
      });
    });
  });

  describe("transferOwnership(address newOwner)", () => {
    afterEach(async function() {
      const currentOwner = await this.brokerageWalletContract.owner();

      if (currentOwner == accounts[1]) {
        await this.brokerageWalletContract.transferOwnership(accounts[0], { from: accounts[1] });
      }
    });

    it("updates the owner address", async function () {
      const currentOwner = await this.brokerageWalletContract.owner();
      await this.brokerageWalletContract.transferOwnership(accounts[1]);
      const newOwner =  await this.brokerageWalletContract.owner();

      assert.notEqual(currentOwner, newOwner);
    });

    it("emits an event", async function () {
      const currentOwner = await this.brokerageWalletContract.owner();
      await this.brokerageWalletContract.transferOwnership(accounts[1]).then(async (result) => {
        truffleAssert.eventEmitted(result, 'OwnershipTransferred', (ev) => {
          return ev.previousOwner === accounts[0] && ev.newOwner === accounts[1];
        });
      });
    });

    context("when called by non-owner", async function () {
      it("raises an exception and does not update the address", async function () {
        await truffleAssert.fails(
          this.brokerageWalletContract.transferOwnership.call(accounts[1], { from: accounts[1] })
        );
      });
    });
  })
});
