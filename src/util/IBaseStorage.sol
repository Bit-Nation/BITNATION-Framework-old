pragma soldity ^0.4.13;


/// @title IBaseStorage
/// @author Eliott Teissonniere
/// @dev Interface for BaseStorage
interface IBaseStorage {
    function getThis() constant public returns (address);
    function getCore() constant public returns (address);
}
