// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../../interfaces/internal/roles/IAdminRole.sol";
import "../../interfaces/internal/roles/IOperatorRole.sol";

error MuseionTreasuryNode_Address_Is_Not_A_Contract();
error MuseionTreasuryNode_Caller_Not_Admin();
error MuseionTreasuryNode_Caller_Not_Operator();

/**
 * @title A mixin that stores a reference to the Museion treasury contract.
 * @notice The treasury collects fees and defines admin/operator roles.
 * @author batu-inal & HardlyDifficult
 */
abstract contract MuseionTreasuryNode {
  using AddressUpgradeable for address payable;

  /// @dev This value was replaced with an immutable version.
  address payable private __gap_was_treasury;

  /// @notice The address of the treasury contract.
  address payable private immutable treasury;

  /// @notice Requires the caller is a Museion admin.
  modifier onlyMuseionAdmin() {
    if (!IAdminRole(treasury).isAdmin(msg.sender)) {
      revert MuseionTreasuryNode_Caller_Not_Admin();
    }
    _;
  }

  /// @notice Requires the caller is a Museion operator.
  modifier onlyMuseionOperator() {
    if (!IOperatorRole(treasury).isOperator(msg.sender)) {
      revert MuseionTreasuryNode_Caller_Not_Operator();
    }
    _;
  }

  /**
   * @notice Set immutable variables for the implementation contract.
   * @dev Assigns the treasury contract address.
   */
  constructor(address payable _treasury) {
    if (!_treasury.isContract()) {
      revert MuseionTreasuryNode_Address_Is_Not_A_Contract();
    }
    treasury = _treasury;
  }

  /**
   * @notice Gets the Museion treasury contract.
   * @dev This call is used in the royalty registry contract.
   * @return treasuryAddress The address of the Museion treasury contract.
   */
  function getMuseionTreasury() public view returns (address payable treasuryAddress) {
    treasuryAddress = treasury;
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[2_000] private __gap;
}
