const KorpusToken_Deposit = artifacts.require("KorpusToken_Deposit");
const KorpusToken_Investment = artifacts.require("KorpusToken_Investment");
const KorpusContract = artifacts.require("KorpusContract");

module.exports = async function (deployer) {
    await deployer.deploy(KorpusToken_Deposit);
    await deployer.deploy(KorpusToken_Investment);
    await deployer.deploy(KorpusContract, KorpusToken_Investment.address, KorpusToken_Deposit.address);
};