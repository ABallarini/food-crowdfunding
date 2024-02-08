// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * Contract **Founds**
 */
contract Founds {
    uint256 public saldo = 0;
    address payable owner;

    uint256 public goal;

    uint256 public countDonators = 0;
    mapping(address => bool) internal donators;

    // the closed variable determines if the collection is completed
    // - True --> closed
    // - False --> open
    bool closed = false;

    function etherValue(uint value) internal pure returns (uint){
        return (value * 1 ether);
    }
    
    constructor(uint256 target) {
        owner = payable(msg.sender);
        goal = etherValue(target);
    }

    modifier goalReached() {
        require(closed == false, "Goal reached, the found is closed");
        _;
    }

    modifier positiveValue() {
        require(msg.value > 0, "Not money");
        _;
    }

    
    /// function used to donate an amount of money
    function donate() public payable positiveValue goalReached {
        // Increment the saldo
        saldo += msg.value;

        // Add the donator to the mapping if not added before and increment the count
        if (!donators[msg.sender]){
            donators[msg.sender] = true;
            countDonators++;
        }
        

        // call the closeCheck function
        closeCheck();

    }

    modifier ownerCheck() {
        require(owner == msg.sender, "You're not the owner");
        _;
    }
    modifier saldoCheck(uint value) {
        require(saldo >= etherValue(value), "Saldo is not enough");
        _;
    }

    /// Function that allow the manager (only) to take an amount of money
    function take(uint256 value) public payable ownerCheck saldoCheck(value) {
        uint ethers = etherValue(value);
        (bool sent, ) = owner.call{value: ethers}("");
        require(sent, "Failed sent");

        // decrease of saldo
        saldo -= ethers;

        // reopen the fund if the goal is less than the saldo
        if (!goalCheck()) {
            closed = false;
        }
    }

    /// function that check and close the fund in case of reaching the goal
    function closeCheck() internal {
        if (goalCheck()) {
            closed = true;
        }
    }

    /// function that check if the saldo is greater or equal to the goal
    function goalCheck() internal view returns (bool) {
        return (saldo >= goal);
    }

    
}