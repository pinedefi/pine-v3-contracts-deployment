# pine-v3-contracts-deployment

## Local development prerequisites
[Install Foundry](https://book.getfoundry.sh/getting-started/installation)
```bash
curl -L https://foundry.paradigm.xyz | bash
# If on MacOS run also this command
brew install libusb
```

| Name \ Network           | Ethereum                                                                                                              | Polygon                                                                                                                  | Eth Sepolia                                                                                                                   | Arbitrum                                                                                                             | Avalanche                                                                                                             |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| factory                  |                                                                                                                       | [0x3d792a021758cd90c728e405c85aacf417db259d](https://polygonscan.com/address/0x3d792a021758cd90c728e405c85aacf417db259d) | [0xfe038D11cEE45810cED4b293F984bA63fCB5406a](https://sepolia.etherscan.io/address/0xfe038D11cEE45810cED4b293F984bA63fCB5406a) | [0xFE03F71C629115D1C0a4FEbF91Ad3334d4E1cBc5](https://arbiscan.io/address/0xFE03F71C629115D1C0a4FEbF91Ad3334d4E1cBc5) | [0xdb9259261980e6e38f75b272fd903e09173f3f2f](https://snowtrace.io/address/0xdb9259261980e6e38f75b272fd903e09173f3f2f) |
| controlPlaneAddress      | [0x9C2780F9e427E29Ba77EDC34C3F42e0865C3FBDF](https://etherscan.io/address/0x9C2780F9e427E29Ba77EDC34C3F42e0865C3FBDF) | [0x85b609f4724860fead57e16175e66cf1f51bf72d](https://polygonscan.com/address/0x85b609f4724860fead57e16175e66cf1f51bf72d) | [0xf334C16F90B826208262c43d0eDe22B33902a0F1](https://sepolia.etherscan.io/address/0xf334C16F90B826208262c43d0eDe22B33902a0F1) | [0x46031553804e733dF8a38FaBE319bB7C888771D7](https://arbiscan.io/address/0x46031553804e733dF8a38FaBE319bB7C888771D7) | [0xac8e3c7b9ae7d8e1a3b360d2e59ed687a4aa68e4](https://snowtrace.io/address/0xac8e3c7b9ae7d8e1a3b360d2e59ed687a4aa68e4) |
| routerAddress            | [0x19C56cb20e6E9598fC4d22318436f34981E481F9](https://etherscan.io/address/0x19C56cb20e6E9598fC4d22318436f34981E481F9) | [0x125488d05fe1d48a8b9053b7c1b021aef08f1c02](https://polygonscan.com/address/0x125488d05fe1d48a8b9053b7c1b021aef08f1c02) | [0x1E2a7d6901117D1309b9f292e30F3A3bB323aecd](https://sepolia.etherscan.io/address/0x1E2a7d6901117D1309b9f292e30F3A3bB323aecd) | [0x27c4EB960B599152adCEc72c60C05FfF0A20BFF1](https://arbiscan.io/address/0x27c4EB960B599152adCEc72c60C05FfF0A20BFF1) | [0x87a3606fd8cb685e72259a25e760df62c3597a26](https://snowtrace.io/address/0x87a3606fd8cb685e72259a25e760df62c3597a26) |
| rolloverRouterAddress    | [0xA5835dB17E67c8D55c472Bb1B1711ccf4D91Bcd6](https://etherscan.io/address/0xA5835dB17E67c8D55c472Bb1B1711ccf4D91Bcd6) | [0x03542e5D86e39304FE347c779De78F3157ca3e6f](https://polygonscan.com/address/0x03542e5D86e39304FE347c779De78F3157ca3e6f) | [0x4f22042D387910E33e2bbEFB24AfbE87A51C3614](https://sepolia.etherscan.io/address/0x4f22042D387910E33e2bbEFB24AfbE87A51C3614) | [0x86db5a0feB709199AF6686c71c19cD17057Bd55E](https://arbiscan.io/address/0x86db5a0feB709199AF6686c71c19cD17057Bd55E) | [0x346290665dac6ed42fa3d80c443215a4311f8ac0](https://snowtrace.io/address/0x346290665dac6ed42fa3d80c443215a4311f8ac0) |
| lendingPoolBeaconAddress | [0x90dFb72736481BBacc7938d2D3673590B92647AE](https://etherscan.io/address/0x90dFb72736481BBacc7938d2D3673590B92647AE) | [0xd3c40c71576d1ba0b2dd476e783e73a359fc3622](https://polygonscan.com/address/0xd3c40c71576d1ba0b2dd476e783e73a359fc3622) | [0x1c7386d8824eA89A70062AA79dB290e3Ab3cEdB7](https://sepolia.etherscan.io/address/0x1c7386d8824eA89A70062AA79dB290e3Ab3cEdB7) | [0xfb0494a40c999b26e0ec945faf7efaca9263a9b8](https://arbiscan.io/address/0xfb0494a40c999b26e0ec945faf7efaca9263a9b8) | [0xe7f7de0665da4d241974e06c46ecaa02dff3e44c](https://snowtrace.io/address/0xe7f7de0665da4d241974e06c46ecaa02dff3e44c) |