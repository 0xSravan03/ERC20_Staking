const { network } = require("hardhat")

async function MoveTime(amount) {
    await network.provider.send("evm_increaseTime", [amount])
    console.log(`Moved ${amount} seconds`)
}

module.exports = {
    MoveTime,
}
