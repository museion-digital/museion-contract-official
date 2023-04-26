// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

/**
 * @notice Interface for functions the market uses in METH.
 * @author batu-inal & HardlyDifficult
 */
interface IMethMarket {
  function depositFor(address account) external payable;

  function marketLockupFor(address account, uint256 amount, uint256 duration) external payable returns (uint256 expiration);

  function marketWithdrawFrom(address from, uint256 amount) external;

  function marketWithdrawLocked(
    address account,
    uint256 expiration,
    uint256 amount
  ) external;

  function marketUnlockFor(
    address account,
    uint256 expiration,
    uint256 amount
  ) external;

  function marketChangeLockup(
    address unlockFrom,
    uint256 unlockExpiration,
    uint256 unlockAmount,
    address lockupFor,
    uint256 lockupAmount,
    uint256 duration
  ) external payable returns (uint256 expiration);
}
