pragma solidity 0.8.3;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ERC721LendingPool02 {
    function durationSeconds_poolParam(uint256 tenor) external view returns (uint32 a, uint32 b);
    function _supportedCurrency() external view returns (address a);
    function _fundSource() external view returns (address a);
}

contract PoolHelper {
  struct LoanOption {
    address poolAddress;
    uint256 durationSeconds;
    uint32 interestBPS1000000XBlock;
    uint32 collateralFactorBPS;
  }

  uint256[3] tenors = [1, 604800, 1209600];

  function checkLoanOptions(address[] calldata addresses) external view returns (LoanOption[] memory) {
    uint256 addressesLength = addresses.length;
    LoanOption[] memory loanOptions = new LoanOption[](addressesLength*3);
    uint256 k;
    for (uint256 i; i < addressesLength; i++) {
      for (uint256 j; j<3; j++) {
        (uint32 a, uint32 b) = ERC721LendingPool02(addresses[i]).durationSeconds_poolParam(tenors[j]);
        if (b > 0) {
          loanOptions[k] = LoanOption(addresses[i], tenors[j], a, b);
          unchecked {
            ++k;
          }
        }
      }
    }
    return loanOptions;
  }

  function checkPoolValidity(address[] calldata addresses) external view returns (bool[] memory) {
    uint256 addressesLength = addresses.length;
    bool[] memory validities = new bool[](addressesLength);
    for (uint256 i; i < addressesLength; i++) {
      address fundSource = ERC721LendingPool02(addresses[i])._fundSource();
      validities[i] = (IERC20(ERC721LendingPool02(addresses[i])._supportedCurrency()).allowance(fundSource, addresses[i]) > 100000000000000000000);
    }
    return validities;
  }
}
