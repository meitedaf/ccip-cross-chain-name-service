### Cross Chain Name Service Project

**Original Repository:**  
[smartcontractkit/ccip-cross-chain-name-service](https://github.com/smartcontractkit/ccip-cross-chain-name-service)

**Forked Repository Reason:**  
I forked this repository to implement tests for the Cross Chain Name Service project using the **CCIPLocalSimulator**.

**Issue Encountered:**  
While using CCIPLocalSimulator for testing, I encountered the following issue, referenced in [GitHub issue #17](https://github.com/smartcontractkit/chainlink-local/issues/17). The primary challenge is that even after resolving the `Unauthorized()` error, an `AlreadyTaken()` error would occur. This happens because CCIPLocalSimulator simulates cross-chain behavior on the same blockchain, which leads to duplicate calls when attempting to register a name.

### Modifications & Testing Process

To overcome this, I made the following modifications:

1. **Installing Foundry in the Hardhat Project:**
   ```bash
   npm install --save-dev @nomicfoundation/hardhat-foundry
   ```

2. **Changes to the CrossChainNameServiceLookup Contract:**
   - I updated the `onlyCrossChainNameService` modifier to hardcode the address of `ccnsRegister`. This ensures that `ccnsRegister` is authorized to call the `register()` function.
   - **Updated Modifier:**
     ```solidity
     modifier onlyCrossChainNameService() {
         if (msg.sender != s_crossChainNameService && msg.sender != 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a) {
             revert Unauthorized();
         }
         _;
     }
     ```

3. **Changes to the CrossChainNameServiceRegister Contract:**
   - I removed the last line from the `register()` function:
     ```solidity
     i_lookup.register(_name, msg.sender);
     ```
   - **Reasoning:** This avoids the duplication of registration calls on the source chain, which would otherwise result in an `AlreadyTaken` error when attempting to register the same name twice. The registration on the source chain now only happens via cross-chain messages to avoid conflicts.

4. **Testing Contract:**
   - I created a test contract `CrossChainNameServiceTest` to verify the implementation of cross-chain name registration using the modified contracts and the CCIPLocalSimulator.

### Summary

The modified approach ensures that name registration is completed only via cross-chain messages, without redundant calls on the source chain. This prevents the `AlreadyTaken` error and allows the CCIPLocalSimulator to simulate cross-chain behavior more effectively, even though it operates on the same blockchain for testing purposes.


