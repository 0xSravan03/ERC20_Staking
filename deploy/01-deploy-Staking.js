const { ethers } = require("hardhat")

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deployer } = await getNamedAccounts()
    const { deploy, log, get } = deployments

    const RTAddress = (await get("RewardToken")).address

    const ARGS = [RTAddress, RTAddress]

    log("Deploying Staking Contract...")
    const Staking = await deploy("Staking", {
        from: deployer,
        args: ARGS,
        log: true,
    })
    log(`Contract Deployed at : ${Staking.address}`)
}

module.exports.tags = ["all", "staking"]
