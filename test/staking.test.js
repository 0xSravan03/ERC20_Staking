const { ethers, getNamedAccounts, deployments } = require("hardhat")
const { assert, expect } = require("chai")
const { MoveBlocks } = require("../utils/move-blocks")
const { MoveTime } = require("../utils/move-time")

describe("Staking", function () {
    let Staking, RToken
    it("should mint all tokens", async () => {
        await deployments.fixture(["all"]) // deploying all contracts for testing
        const { deployer } = await getNamedAccounts()
        RToken = await ethers.getContract("RewardToken", deployer)
        Staking = await ethers.getContract("Staking", deployer)
        const eresult = "1000000.0"
        const result = await RToken.totalSupply()
        assert.equal(eresult, ethers.utils.formatEther(result).toString())
    })

    it("allow user to stake and claim", async () => {
        const { tester, deployer } = await getNamedAccounts()
        const StakeAmt = ethers.utils.parseEther("100")
        const approveTx = await RToken.approve(Staking.address, StakeAmt)
        await approveTx.wait()
        const tx = await Staking.stake(StakeAmt)
        await tx.wait()
        const signer = await ethers.getNamedSigner("deployer")
        const startingEarned = await Staking.earned(signer.address)
        const BalanceOfUser = await Staking.s_balances(signer.address)
        assert.equal(BalanceOfUser.toString(), StakeAmt.toString())
        console.log(`Starting Earned : ${startingEarned}`)
        // Move Time
        await MoveTime(86400) // 86400 seconds - 1 Day
        await MoveBlocks(1)

        const endingEarned = await Staking.earned(signer.address)
        console.log(`Ending Earned : ${endingEarned}`)
        expect(endingEarned).to.be.greaterThan(startingEarned)

        const tx1 = await RToken.transfer(tester, ethers.utils.parseEther("50"))
        await tx1.wait()

        const signerTest = await ethers.getNamedSigner("tester")

        const RTokenNew = await RToken.connect(signerTest)
        const tx2 = await RTokenNew.approve(
            Staking.address,
            ethers.utils.parseEther("40")
        )
        await tx2.wait()

        const StakeTest = await Staking.connect(signerTest)

        const stakeTx = await StakeTest.stake(ethers.utils.parseEther("40"))
        await stakeTx.wait()

        await MoveTime(86400) // 86400 seconds - 1 Day
        await MoveBlocks(1)

        const endingEarnedD = await StakeTest.earned(deployer)
        const endingEarnedT = await StakeTest.earned(tester)

        console.log(`Ending Earned - deployer : ${endingEarnedD}`)
        console.log(`Ending Earned - tester : ${endingEarnedT}`)
    })
})
