pragma solidity 0.8.9;

import "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../libraries/PineLendingLibrary.sol";
import "./ERC721LendingPool.sol";
import "../meta/BeaconProxy.sol";

contract ControlPlane01 is OwnableUpgradeable {
  uint constant PRECISION = 1000000000000;
  address public whitelistedFactory;
  uint32 public feeBps;
  mapping (address => bool) public whitelistedIntermediaries;
  mapping (address => bool) public targets;
  mapping (address => bool) public genuineClone;
  address public _feeStructure;

  event Liquidation(address indexed supportedCollection, uint256 indexed loanID, address indexed poolAddress);

  constructor() {
    _disableInitializers();
  }

  function initialize(
      address feeStructure
  ) public initializer {
      whitelistedFactory = address(this);
      feeBps = 0;
      _feeStructure = feeStructure;
      __Ownable_init();
  }

  function changeFeeStructure(address feeStructure) external onlyOwner {
      _feeStructure = feeStructure;
  }
  
  function toggleWhitelistedIntermediaries(address target) external onlyOwner {
    whitelistedIntermediaries[target] = !whitelistedIntermediaries[target];
  }

  function setFee(uint32 f) external onlyOwner {
    require(f < 10000);
    feeBps = f;
  }

  function ceil(uint a, uint m) public pure returns (uint ) {
      return ((a + m - 1) / m) * m;
  }

  function outstanding(PineLendingLibrary.LoanTerms calldata loanTerms, uint txSpeedBlocks) external view returns (uint256) {
    uint adjustedO = PineLendingLibrary.outstanding(loanTerms, txSpeedBlocks);
    uint ogO = PineLendingLibrary.outstanding(loanTerms);
    if (adjustedO != ogO) {
      return ceil(adjustedO, PRECISION);
    } else {
      return ogO;
    }
  }

  function outstanding(PineLendingLibrary.LoanTerms calldata loanTerms) external view returns (uint256) {
    return PineLendingLibrary.outstanding(loanTerms);
  }

  function withdraw(uint256 amount) external onlyOwner {
        (bool success, ) = owner().call{value: amount}("");
        require(success, "cannot send ether");
    }

  function withdrawERC20(address currency, uint256 amount) external onlyOwner {
      require(IERC20(currency).transfer(owner(), amount));
  }


  // function callLoan() public {

  // }

  function liquidateNFT(address payable target, uint256 loanID) external {
    ERC721LendingPool02 pool = ERC721LendingPool02(target);
    // TODO: check unhealthy
    (uint256 a,
    uint256 b,
    uint32 c,
    ,
    uint256 e,
    uint256 f,
    uint256 g,
    uint256 h,
    ) = pool._loans(loanID);
    PineLendingLibrary.LoanTerms memory lt = PineLendingLibrary.LoanTerms(a,b,c,0,e,f,g,h,address(0));
    (bool unhealthy, ) = PineLendingLibrary.isUnHealthyLoan(lt);
    require(unhealthy, "Loan is not liquidable");
    pool.withdrawERC721(pool._supportedCollection(), loanID, pool.owner(), true);
    emit Liquidation(pool._supportedCollection(), loanID, address(pool));
  }

  function withdrawNFT(address payable target, address nft, uint256 id) external onlyOwner {
    ERC721LendingPool02 pool = ERC721LendingPool02(target);
    // TODO: check unhealthy
    (uint256 a,
    uint256 b,
    uint32 c,
    ,
    uint256 e,
    uint256 f,
    uint256 g,
    uint256 h,
    ) = pool._loans(id);
    PineLendingLibrary.LoanTerms memory lt = PineLendingLibrary.LoanTerms(a,b,c,0,e,f,g,h,address(0));
    (bool has) = PineLendingLibrary.nftHasLoan(lt);
    require(!has, "Loan is active");
    pool.withdrawERC721(nft, id, owner(), false);
  }


  event PoolCreated(
    address indexed result,
    address indexed supportedCollection,
    address indexed supportedCurrency,
    address target,
    address fundSource,
    uint256 duration, 
    ERC721LendingPool02.PoolParams ppm
  );

  function createClone(address target, bytes32 salt, address supportedCollection, address valuationSigner, address supportedCurrency, address fundSource, uint256 duration, ERC721LendingPool02.PoolParams calldata ppm, uint256 ethLimit) public returns (address result) {
    require(targets[target]);
    // bytes20 targetBytes = bytes20(target);
    // assembly {
    //   let clone := mload(0x40)
    //   mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
    //   mstore(add(clone, 0x14), targetBytes)
    //   mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
    //   result := create2(0, clone, 0x37, salt)
    // }
    BeaconProxy bp = new BeaconProxy{salt: salt}(target, "");
    address result2 = address(bp);

    // initialize
    ERC721LendingPool02(result2).initialize(supportedCollection, valuationSigner, address(this), supportedCurrency, fundSource, _feeStructure, ethLimit);

    // create offer
    ERC721LendingPool02(result2).setDurationParam(duration, ppm);

    ERC721LendingPool02(result2).setBlockLoanLimit(2000000000000000000000000);
    ERC721LendingPool02(result2).transferOwnership(msg.sender);
    genuineClone[result2] = true;
    emit PoolCreated(result2, supportedCollection, supportedCurrency, target, fundSource, duration, ppm);
    return result2;
  }

  function toggleWhitelistedTarget(address target) external onlyOwner {
    targets[target] = !targets[target];
  }
}