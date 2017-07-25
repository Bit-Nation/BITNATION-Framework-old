pragma solidity ^0.4.13;


/// @title ICore
/// @author Eliott Teissonniere
/// @dev Basic interface all cores need to implement
interface ICore {
    // Should only be called once, at setup time
    function setup(address baseCoreAddr) public;

    // Authorization are managed by ds-auth, ds-group or ds-guard
}
