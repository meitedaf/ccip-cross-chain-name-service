// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CrossChainNameServiceLookup} from "contracts/CrossChainNameServiceLookup.sol";
import {CrossChainNameServiceReceiver} from "contracts/CrossChainNameServiceReceiver.sol";
import {CrossChainNameServiceRegister} from "contracts/CrossChainNameServiceRegister.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import {CCIPLocalSimulator} from "lib/chainlink-local/src/ccip/CCIPLocalSimulator.sol";
import {
    IRouterClient, WETH9, LinkToken, BurnMintERC677Helper
} from "lib/chainlink-local/src/ccip/CCIPLocalSimulator.sol";

contract CrossChainNameServiceTest is Test {
    CCIPLocalSimulator public ccipLocalSimulator;
    CrossChainNameServiceRegister public ccnsRegister;
    CrossChainNameServiceReceiver public ccnsReveiver;
    CrossChainNameServiceLookup public ccnsLookup;
    uint256 public constant GAS_LIMIT = 200000;
    uint256 public constant REQUEST_LINK_AMOUT = 1 ether;
    address public Alice = makeAddr("Alice");
    uint64 public chainSelector;
    IRouterClient public sourceRouter;
    IRouterClient public destinationRouter;
    WETH9 public wrappedNative;
    LinkToken public linkToken;
    BurnMintERC677Helper public ccipBnM;
    BurnMintERC677Helper public ccipLnM;

    function setUp() public {
        ccipLocalSimulator = new CCIPLocalSimulator();
        (chainSelector, sourceRouter, destinationRouter, wrappedNative, linkToken, ccipBnM, ccipLnM) =
            ccipLocalSimulator.configuration();

        ccnsLookup = new CrossChainNameServiceLookup();
        ccnsRegister = new CrossChainNameServiceRegister(address(sourceRouter), address(ccnsLookup));
        ccnsReveiver = new CrossChainNameServiceReceiver(address(destinationRouter), address(ccnsLookup), chainSelector);

        ccnsLookup.setCrossChainNameServiceAddress(address(ccnsReveiver));
        console.log("Authorized address set to:", address(ccnsReveiver));
    }

    function testCCNSSuccess() public {
        // Arrange
        ccnsRegister.enableChain(chainSelector, address(ccnsReveiver), GAS_LIMIT);
        ccipLocalSimulator.requestLinkFromFaucet(address(ccnsRegister), REQUEST_LINK_AMOUT);
        // ACT
        vm.prank(Alice);
        ccnsRegister.register("alice.ccns");
        address expectAddress = ccnsLookup.lookup("alice.ccns");
        // Assert
        assertEq(expectAddress, Alice);
    }
}
