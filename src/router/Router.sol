pragma solidity 0.8.9;
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../interfaces/WETH.sol";


interface NewERC721LendingPool02 {

  function _supportedCurrency() external view returns (address);
  function _supportedCollection() external view returns (address);

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

}

contract Router01 is OwnableUpgradeable {

  address WETHaddr;
  address payable controlPlane;
  uint fee;

  constructor() {
    _disableInitializers();
  }

  function init(address w, address payable c) initializer external {
    __Ownable_init();
    WETHaddr = w;
    controlPlane = c;
    fee = 0;
  }

  function setFee(uint f) public onlyOwner {
    fee = f;
  }

  function batchBorrow(
    address payable[] memory targets, 
    uint256[] memory valuation,
    uint256[] memory nftID,
    uint256[] memory loanDurationSeconds,
    uint256[] memory expireAtBlock,
    uint256[] memory borrowedWei,
    bytes[] memory signature,
    address pineWallet
  ) public {
    for (uint16 i = 0; i < targets.length; i ++) {
      address currency = NewERC721LendingPool02(targets[i])._supportedCurrency();
      address collection = NewERC721LendingPool02(targets[i])._supportedCollection();
      require(IERC721(collection).ownerOf(nftID[i]) == msg.sender, "User not owning NFT");
      IERC721(collection).setApprovalForAll(targets[i], true);
      IERC721(collection).transferFrom(msg.sender, address(this), nftID[i]);
      NewERC721LendingPool02(targets[i]).borrow([valuation[i], nftID[i], loanDurationSeconds[i], expireAtBlock[i], borrowedWei[i]], signature[i], msg.sender, pineWallet);
      IERC20(currency).transfer(controlPlane, fee);
      IERC20(currency).transfer(msg.sender, IERC20(currency).balanceOf(address(this)));
    }
  }

  function batchBorrowETH(
    address payable[] memory targets, 
    uint256[] memory valuation,
    uint256[] memory nftID,
    uint256[] memory loanDurationSeconds,
    uint256[] memory expireAtBlock,
    uint256[] memory borrowedWei,
    bytes[] memory signature,
    address pineWallet
  ) public {
    for (uint16 i = 0; i < targets.length; i ++) {
      address currency = NewERC721LendingPool02(targets[i])._supportedCurrency();
      require(currency == WETHaddr, "only works for WETH");
      address collection = NewERC721LendingPool02(targets[i])._supportedCollection();
      require(IERC721(collection).ownerOf(nftID[i]) == msg.sender, "User not owning NFT");
      IERC721(collection).setApprovalForAll(targets[i], true);
      IERC721(collection).transferFrom(msg.sender, address(this), nftID[i]);
      NewERC721LendingPool02(targets[i]).borrow([valuation[i], nftID[i], loanDurationSeconds[i], expireAtBlock[i], borrowedWei[i]], signature[i], msg.sender, pineWallet);
    }

    WETH9(payable(WETHaddr)).transfer(controlPlane, fee);

    WETH9(payable(WETHaddr)).withdraw(IERC20(WETHaddr).balanceOf(address(this)));
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "cannot send ether");
  }

  function repayETH(address payable target, uint nftID, address pineWallet) payable public {
    address currency = NewERC721LendingPool02(target)._supportedCurrency();
    require(currency == WETHaddr, "only works for WETH");
    WETH9(payable(currency)).deposit{value: msg.value}();
    IERC20(payable(currency)).approve(target, 999999999999999999999999999);
    _repay(target, nftID, msg.value, pineWallet);
    WETH9(payable(currency)).withdraw(IERC20(currency).balanceOf(address(this)));
    IERC20(payable(currency)).approve(target, 0);
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "cannot send ether");
  }

  function _repay(address payable target, uint nftID, uint256 repayAmount, address pineWallet) internal {
    NewERC721LendingPool02(target).repay(nftID, repayAmount, pineWallet);
  }

  function withdraw(uint256 amount) external onlyOwner {
      (bool success, ) = owner().call{value: amount}("");
      require(success, "cannot send ether");
  }

  function withdrawERC20(address currency, uint256 amount) external onlyOwner {
      IERC20(currency).transfer(owner(), amount);
  }
  
  receive() external payable {

  }

}
