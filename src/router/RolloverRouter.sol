pragma solidity 0.8.9;
import "../core/ControlPlane.sol";
import "../interfaces/WETH.sol";

interface IERC721LendingPool02 {

  function _supportedCurrency() external view returns (address);
  function _supportedCollection() external view returns (address);
  function _loans(uint) external view returns (PineLendingLibrary.LoanTerms memory);
  function _fundSource() external view returns (address);
  function borrow(
      uint256[5] calldata x,
      bytes memory signature,
      address borrowFor,
      address pineWallet
  ) external returns (bool);

  function repay(
      uint256 nftID,
      uint256 repayAmount,
      address pineWallet
  ) external returns (bool);
  function flashLoan(
        address payable _receiver,
        address _reserve,
        uint256 _amount,
        bytes memory _params
  ) external ;

}

contract RolloverRouter01 is IFlashLoanReceiver, OwnableUpgradeable {
    
    ControlPlane01 public rcp;
    mapping (address => bool) operators;


    function toggleOperator(address operator) external onlyOwner {
        operators[operator] = !operators[operator];
    }

    constructor() {
      _disableInitializers();
    }

    function init(ControlPlane01 _rcp) external initializer {
      __Ownable_init();
      rcp = _rcp;
    }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) external override {
        require(rcp.genuineClone(msg.sender), "Cannot authenticate sender");
        // repay the loan
        address payable currentFlashLoanSource;
        address payable currentLendingPool;
        address payable targetLendingPool;
        address currency;
        // uint256 valuation;
        // uint256 nftID;
        // uint256 loanDurationSeconds;
        // uint256 expireAtBlock;
        // uint256 borrowedWei;
        // uint256 outstanding;
        uint256[6] memory numbers;
        address pineWallet;
        bytes memory signature;
        (
            currency,
            currentFlashLoanSource,
            currentLendingPool,
            targetLendingPool,
            numbers,
            signature,
            pineWallet
        ) = abi.decode(
            _params,
            (address, address, address, address, uint256[6], bytes, address)
        );
        require(rcp.genuineClone(currentFlashLoanSource), "Cannot authenticate currentFlashLoanSource");
        require(rcp.genuineClone(currentLendingPool), "Cannot authenticate currentLendingPool");
        require(rcp.genuineClone(targetLendingPool), "Cannot authenticate targetLendingPool");
        IERC20(currency).approve(currentLendingPool, numbers[5]);
        address currentBorrower = IERC721LendingPool02(currentLendingPool)._loans(numbers[1]).borrower;
        require(
            IERC721LendingPool02(currentLendingPool).repay(
                numbers[1],
                numbers[5],
                pineWallet
            )
        );
        IERC721(IERC721LendingPool02(currentLendingPool)._supportedCollection()).transferFrom(currentBorrower, address(this), numbers[1]);
        IERC721(IERC721LendingPool02(currentLendingPool)._supportedCollection()).setApprovalForAll(targetLendingPool, true);
        IERC721LendingPool02(targetLendingPool).borrow(
            [numbers[0], numbers[1], numbers[2], numbers[3], numbers[4]],
            signature,
            currentBorrower,
            pineWallet
        );
        if (_amount + _fee > numbers[4]) {
          require(address(this).balance >= _amount + _fee - numbers[4], "rollover is not covered");
        }
        
        WETH9(payable(currency)).deposit{value: address(this).balance}();
        require(IERC20(currency).transfer(
            IERC721LendingPool02(currentFlashLoanSource)._fundSource(),
            _amount + _fee
        ));
        uint256 addressRemainingBalance = IERC20(currency).balanceOf(address(this));
        if (addressRemainingBalance > 0) {
          WETH9(payable(currency)).withdraw(addressRemainingBalance);
          (bool success, ) = tx.origin.call{value: address(this).balance}("");
          require(success, "cannot send ether");
        }
    }

    function rover(
        address payable flashLoanSource,
        address payable lendingPool,
        address payable targetLendingPool,
        uint256[6] calldata numbers,
        bytes memory signature,
        address pineWallet
    ) external payable {
        address currency = IERC721LendingPool02(lendingPool)
            ._supportedCurrency();

        require(msg.sender == IERC721LendingPool02(lendingPool)._loans(numbers[1]).borrower || operators[msg.sender] || msg.sender == owner(), "Wrong operator");
        
        IERC721LendingPool02(flashLoanSource).flashLoan(
            payable(this),
            currency,
            numbers[5],
            abi.encode(
                currency,
                flashLoanSource,
                lendingPool,
                targetLendingPool,
                numbers,
                signature,
                pineWallet
            )
        );
    }

    receive() external payable {
        // React to receiving ether
    }
}