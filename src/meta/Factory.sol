pragma solidity 0.8.9;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "./TransparentUpgradeableProxy.sol";
import "./BeaconProxy.sol";
import "./UpgradeableBeacon.sol";
import "../core/ControlPlane.sol";
import "../core/ERC721LendingPool.sol";
import "../router/RolloverRouter.sol";
import "../router/Router.sol";
import "../libraries/FeeStructure.sol";

contract Factory is Ownable {

    address payable public controlPlaneAddress;
    address payable public lendingPoolBeaconAddress;
    address payable public rolloverRouterAddress;
    address payable public routerAddress;
    address public feeStructureAddress;

    constructor() {
        ControlPlane01 controlPlane = new ControlPlane01();
        ERC721LendingPool02 lendingPool = new ERC721LendingPool02();
        RolloverRouter01 rolloverRouter = new RolloverRouter01();
        Router01 router = new Router01();

        FeeStructure feeStructure = new FeeStructure();
        feeStructureAddress = address(feeStructure);

        TransparentUpgradeableProxy controlPlaneProxy = new TransparentUpgradeableProxy(address(controlPlane), address(this), "");
        controlPlaneAddress = payable(address(controlPlaneProxy));

        UpgradeableBeacon lendingPoolBeacon = new UpgradeableBeacon(address(lendingPool));
        lendingPoolBeaconAddress = payable(address(lendingPoolBeacon));

        TransparentUpgradeableProxy rolloverRouterProxy = new TransparentUpgradeableProxy(address(rolloverRouter), address(this), "");
        rolloverRouterAddress = payable(address(rolloverRouterProxy));

        TransparentUpgradeableProxy routerProxy = new TransparentUpgradeableProxy(address(router), address(this), "");
        routerAddress = payable(address(routerProxy));
    }

    function upgradeImplementation(TransparentUpgradeableProxy proxy, address newImplementation) external onlyOwner {
        proxy.upgradeTo(newImplementation);
    }
}