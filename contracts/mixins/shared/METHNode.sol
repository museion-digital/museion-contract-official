// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../../interfaces/internal/IMethMarket.sol";

error METHNode_METH_Address_Is_Not_A_Contract();
error METHNode_Only_METH_Can_Transfer_ETH();

/**
 * @title A mixin for interacting with the METH contract.
 * @author batu-inal & HardlyDifficult
 */
abstract contract METHNode {
  using AddressUpgradeable for address;
  using AddressUpgradeable for address payable;

  /// @notice The METH ERC-20 token for managing escrow and lockup.
  IMethMarket internal immutable meth;

  constructor(address _meth) {
    if (!_meth.isContract()) {
      revert METHNode_METH_Address_Is_Not_A_Contract();
    }

    meth = IMethMarket(_meth);
  }

  /**
   * @notice Only used by METH. Any direct transfer from users will revert.
   */
  receive() external payable {
    if (msg.sender != address(meth)) {
      revert METHNode_Only_METH_Can_Transfer_ETH();
    }
  }

  /**
   * @notice Withdraw the msg.sender's available METH balance if they requested more than the msg.value provided.
   * @dev This may revert if the msg.sender is non-receivable.
   * This helper should not be used anywhere that may lead to locked assets.
   * @param totalAmount The total amount of ETH required (including the msg.value).
   * @param shouldRefundSurplus If true, refund msg.value - totalAmount to the msg.sender.
   */
  function _tryUseMETHBalance(uint256 totalAmount, bool shouldRefundSurplus) internal {
    if (totalAmount > msg.value) {
      // Withdraw additional ETH required from the user's available METH balance.
      unchecked {
        // The if above ensures delta will not underflow.
        // Withdraw ETH from the user's account in the METH token contract,
        // making the funds available in this contract as ETH.
        meth.marketWithdrawFrom(msg.sender, totalAmount - msg.value);
      }
    } else if (shouldRefundSurplus && totalAmount < msg.value) {
      // Return any surplus ETH to the user.
      unchecked {
        // The if above ensures this will not underflow
        payable(msg.sender).sendValue(msg.value - totalAmount);
      }
    }
  }

  /**
   * @notice Gets the METH contract used to escrow offer funds.
   * @return methAddress The METH contract address.
   */
  function getMethAddress() external view returns (address methAddress) {
    methAddress = address(meth);
  }
}
