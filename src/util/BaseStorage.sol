pragma solidity ^0.4.13;

import "./Storage.sol";
import "./IBaseStorage.sol";

/// @title BaseStorage
/// @author Eliott Teissonniere
/// @dev The base contract which must be used by EVERY module
contract BaseStorage is IBaseStorage, Storage {
    bytes32 constant CORE_KEY = sha3(0x0, 0x1);
    bytes32 constant THIS_KEY = sha3(0x0, 0x0);

    /// @dev used by core and base for delegatecall
    uint32 constant RETURN_MEMORY_SIZE = 24 * 32;

    /// @dev that function is used to set the this reference
    /// @param newThisAddress address: for this
    function setThis(address newThisAddress) internal {
        setStorage(THIS_KEY, uint256(newThisAddress));
    }

    /// @notice return the address of this
    /// @return address of `this`
    function getThis() constant public returns (address) {
        return address(getStorage(THIS_KEY));
    }

    /// @dev set the new core
    /// @param newCoreAddress address of the core contract
    function setCore(address newCoreAddress) internal {
        setStorage(CORE_KEY, uint256(newCoreAddress));
    }

    /// @notice get the core contract address
    /// @return address of the core contract
    function getCore() constant public returns (address) {
        return address(getStorage(CORE_KEY));
    }
}
