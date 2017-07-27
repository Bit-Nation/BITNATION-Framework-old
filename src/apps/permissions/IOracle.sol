pragma solidity ^0.4.13;


/// @title IPermissionOracle
/// @author Eliott Teissonniere
/// @dev interface of the permission oracle
interface IPermissionOracle {
    function isAuthorized(address sender, address token, uint256 value, bytes data) constant returns (bool);
}
