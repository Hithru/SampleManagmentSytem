const { ethers, getNamedAccounts } = require("hardhat")

async function main() {
    const { deployer } = await getNamedAccounts()
    const licenseFactory = await ethers.getContract("LicenseFactory", deployer)
    console.log(`Got contract LicenseFactory at ${licenseFactory.address}`)
    console.log("Buying a License contract...")
    const transactionResponse = await licenseFactory.buyLicense({
        value: ethers.utils.parseEther("0.1"),
    })
    await transactionResponse.wait()
    console.log("Bought a License!")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
