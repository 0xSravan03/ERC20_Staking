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
    mapping(address => uint256) public s_rewards;
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    // Total token staked
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public constant REWARD_RATE = 100; // 100 tokens per second

    // Custom Errors
    error Staking__TransferFailed(address from, address to, uint256 amount);
    error Staking__InsufficientTokenToStake(
        uint256 userBalance,
        uint256 requiredAmt
    );

    constructor(address stakingToken) {
        s_stakingToken = IERC20(stakingToken);
    }

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    function rewardPerToken() internal view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) /
                s_totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        uint256 currentBalance = s_balances[account];
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];
        uint256 earnedAmt = ((currentBalance *
            (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
        return earnedAmt;
    }

    /**
     * @dev Allow only a specific token to Stake
     * @param amount Amount of token to Stake
     */
    function stake(uint256 amount) external updateReward(msg.sender) {
        uint256 userTokenBalance = s_stakingToken.balanceOf(msg.sender);
        if (userTokenBalance < amount) {
            revert Staking__InsufficientTokenToStake(userTokenBalance, amount);
        }
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

    /**
     * @dev Allow user to withdraw their Staked Tokens
     * @param amount Withdraw token amount
     */
    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(s_balances[msg.sender] >= amount, "BALANCE_ERROR");
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Staking__TransferFailed(address(this), msg.sender, amount);
        }
    }

    function claimReward() external updateReward(msg.sender) {}

    receive() external payable {}

    fallback() external payable {}
}
