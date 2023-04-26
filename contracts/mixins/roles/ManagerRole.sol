// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./AdminRole.sol";

/**
 * @title Defines a role for manager accounts.
 * @dev Wraps a role from OpenZeppelin's AccessControl for easy integration.
 * @author batu-inal & HardlyDifficult
 */
contract ManagerRole is Initializable, AccessControlUpgradeable, AdminRole {
  constructor(address manager) {
    // Grant the minter role to a specified account
    _grantRole(DEFAULT_ADMIN_ROLE, manager);
  }
}
