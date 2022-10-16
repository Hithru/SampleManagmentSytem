const { deployments, ethers, getNamedAccounts } = require("hardhat")
const { assert, expect } = require("chai")
describe("LicenseFactory", async function () {
    let fundMe
    let deployer
    let mockV3aggregator
    const sendValue = ethers.utils.parseEther("1")
    beforeEach(async () => {
        // const accounts = await ethers.getSigners()
        // deployer = accounts[0]
        deployer = (await getNamedAccounts()).deployer
        await deployments.fixture(["all"])
        licenseFactory = await ethers.getContract("LicenseFactory", deployer)
        mockV3Aggregator = await ethers.getContract(
            "MockV3Aggregator",
            deployer
        )
    })

    describe("constructor", function () {
        it("sets the aggregator addresses correctly", async () => {
            const response = await licenseFactory.getPriceFeed()
            assert.equal(response, mockV3Aggregator.address)
        })
    })

    describe("buyLicense", async function () {
        it("Fails if you don't send enough ETH", async () => {
            await expect(licenseFactory.buyLicense()).to.be.revertedWith(
                "License price is Higher!"
            )
        })
    })

    describe("withdraw", function () {
        beforeEach(async () => {
            await licenseFactory.buyLicense({ value: sendValue })
        })

        it("Only allows the owner to withdraw", async function () {
            const accounts = await ethers.getSigners()
            const licenseFactoryContract = await licenseFactory.connect(
                accounts[1]
            )
            await expect(licenseFactoryContract.withdraw()).to.be.reverted
        })
    })
})
