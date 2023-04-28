// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// User should able to stake their tokens (Stake)
// Should able to withdraw staked tokens (Withdraw)
// Claim reward based on staking (ClaimReward)

contract Staking {
    IERC20 public immutable s_stakingToken; // ERC20 Token that is allowed to Stake

    // Mapping keep track of staked token amount.
    mapping(address => uint256) public s_balances;
    // Total token staked
    uint256 public s_totalSupply;

    // Custom Errors
    error Staking__TransferFailed(address from, address to, uint256 amount);

    constructor(address stakingToken) {
        s_stakingToken = IERC20(stakingToken);
    }

    /**
     * @dev Allow only a specific token to Stake
     * @param amount Amount of token to Stake
     */
    function stake(uint256 amount) external {
        require(
            s_stakingToken.balanceOf(msg.sender) >= amount,
            "TOKEN_AMOUNT_ERROR"
        );
        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) {
            revert Staking__TransferFailed(msg.sender, address(this), amount);
        }
        s_balances[msg.sender] += amount;
        s_totalSupply += amount;
    }

    receive() external payable {}

    fallback() external payable {}
}
