require("dotenv").config();

module.exports = {
  networks: {
    mainnet: {
      from: 'TTVnVz6BnrBv8Vyj9doz13tXLiWPj3xLy4',
      privateKey: process.env.PRIVATE_KEY_SHASTA,
      userFeePercentage: 30,
      feeLimit: 1e9,
      originEnergyLimit: 1e7,
      fullHost: "https://api.trongrid.io",
      network_id: "*" // Match any network id
    },
    shasta: {
      privateKey: process.env.PRIVATE_KEY_SHASTA,
      userFeePercentage: 50,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.shasta.trongrid.io',
      network_id: '2'
    },
    nile: {
      privateKey: process.env.PRIVATE_KEY_NILE,
      userFeePercentage: 100,
      feeLimit: 1000 * 1e6,
      fullHost: 'https://api.nileex.io',
      network_id: '3'
    },

    compilers: {
      solc: {
        version: '0.8.0'
      }
    }
  }
};
