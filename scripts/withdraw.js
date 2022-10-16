const { ethers, getNamedAccounts } = require("hardhat")

async function main() {
    const { deployer } = await getNamedAccounts()
    const licenseFactory = await ethers.getContract("LicenseFactory", deployer)
    console.log(`Got contract LicenseFactory at ${licenseFactory.address}`)
    console.log("Withdrawing from contract...")
    const transactionResponse = await licenseFactory.withdraw()
    await transactionResponse.wait()
    console.log("Got it back!")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
