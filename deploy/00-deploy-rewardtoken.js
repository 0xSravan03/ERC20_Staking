const hre = require("hardhat")

module.exports = async () => {
    const { deployer } = await hre.getNamedAccounts()
    const { deploy, log } = hre.deployments

    log("Deploying RewardToken..")
    const RT = await deploy("RewardToken", {
        from: deployer,
        args: [],
        log: true,
    })
    log(`RewardToken deployed at ${RT.address}`)
}

module.exports.tags = ["all", "rewardtoken"]
