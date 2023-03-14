pragma solidity 0.8.9;

import "forge-std/Script.sol";
import "../src/meta/Factory.sol";

contract DeployFactory is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address W = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

        vm.startBroadcast(deployerPrivateKey);

        Factory factory = new Factory();

        ControlPlane01(factory.controlPlaneAddress()).initialize(factory.feeStructureAddress());
        Router01(factory.routerAddress()).init(W, factory.controlPlaneAddress());
        RolloverRouter01(factory.rolloverRouterAddress()).init(ControlPlane01(factory.controlPlaneAddress()));

        ControlPlane01(factory.controlPlaneAddress()).toggleWhitelistedTarget(factory.lendingPoolBeaconAddress());
        ControlPlane01(factory.controlPlaneAddress()).toggleWhitelistedIntermediaries(factory.routerAddress());
        ControlPlane01(factory.controlPlaneAddress()).toggleWhitelistedIntermediaries(factory.rolloverRouterAddress());
        
        vm.stopBroadcast();
    }
}