pragma solidity ^0.4.13;

import "../util/BaseStorage.sol";


/// @title Base
/// @author Eliott Teissonniere
/// @dev this contract is the only not upgradeable one, the whole framework lives on top of that one
contract Base is BaseStorage {
    function Base(address core) {
        setThis(this);
        setCore(core);
        // Ask the core to set itself and its modules up
        assert(core.delegatecall(bytes4(sha3("setup(address)")), core));
    }

    /// @dev forward any calls to the core contract
    function () payable public {
        uint32 return_len = RETURN_MEMORY_SIZE;
        address core = getCore();

        assert(core > 0);

        // Basically:
        // - copy all bytes from call data at position 0x0 to mem at position 0x0 (start of the memory)
        // - do the delegatecall and retrieve result
        // - if call throwed, throw to
        // - return result
        assembly {
            calldatacopy(0x0, 0x0, calldatasize)
            let result := delegatecall(sub(gas, 10000), core, 0x0, calldatasize, 0, return_len)
            jumpi(invalidJumpLabel, iszero(result))
            return(0, return_len)
        }
    }
}
