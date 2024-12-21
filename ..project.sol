// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FitnessChallenge {
    IERC20 public rewardToken;  // The ERC20 token used for rewards
    address public owner;       // Owner of the contract (platform admin)
    
    // Mapping to track users' completed challenges and earned rewards
    mapping(address => uint256) public userPoints;
    mapping(address => bool) public hasParticipated;

    // Event to log earned rewards
    event ChallengeCompleted(address indexed user, uint256 points);

    // Constructor to initialize the contract with the reward token
    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    // Modifier to restrict access to only the owner (admin)
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function to record the completion of a fitness challenge for a user
    function recordChallengeCompletion(address user, uint256 points) public onlyOwner {
        require(!hasParticipated[user], "User has already participated in this challenge");
        
        userPoints[user] += points;
        hasParticipated[user] = true;
        
        emit ChallengeCompleted(user, points);
    }

    // Function to allow users to claim their rewards based on points earned
    function claimReward() public {
        uint256 points = userPoints[msg.sender];
        require(points > 0, "No points to claim");

        uint256 rewardAmount = points * 1 * 10 ** 18; // 1 point = 1 token (adjustable)
        userPoints[msg.sender] = 0; // Reset points after claiming
        
        require(rewardToken.transfer(msg.sender, rewardAmount), "Reward transfer failed");
    }

    // Function to withdraw contract balance (for the owner)
    function withdraw() public onlyOwner {
        uint256 balance = rewardToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");
        require(rewardToken.transfer(owner, balance), "Withdraw failed");
    }

    // Function to change the reward token (for the owner)
    function changeRewardToken(address newToken) public onlyOwner {
        rewardToken = IERC20(newToken);
    }
}
