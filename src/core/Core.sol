pragma solidity ^0.4.13;

import "erc20/erc20.sol";

import "./ICore.sol";

import "../util/BaseStorage.sol";
import "../apps/permissions/IOracle.sol";
import "../apps/IApplication.sol";


/// @title Core
/// @author Eliott Teissonniere
/// @dev core contracts of the dbvn, can be linked to ds-auth authority (ds-roles is embedded)
/// the contract is used to install apps/modules and dispatch calls to the right contracts
/// @dev permissions to use the different functions are controlled via the "permissions" application
contract Core is ICore, BaseStorage {
    uint256 constant ONLY_ONCE_KEY = 0x1;

    bytes32 constant PERMISSION_ORACLE_KEY = sha3(0x1, 0x0);

    bytes4 constant VAULT_DEPOSIT_SIG = bytes4(sha3("deposit(address,uint256)"));

    modifier onlyOnce(string key) {
        require(getStorage(sha3(ONLY_ONCE_KEY, key)) == 0);
        setStorage(sha3(ONLY_ONCE_KEY, key), 1);
        _;
    }

    /// @param baseCoreAddr set by the dbvn, not used at the moment
    function setup(address baseCoreAddr) onlyOnce("setup") {
         // should deploy vault
    }

    // Functions starting the dispatch process

    function () payable public {
         dispatch(msg.sender, 0, msg.value, msg.data);
    }

    function receiveApproval(address sender, uint256 value, address token, bytes data) public {
         assert(ERC20(token).transferFrom(sender, address(this), value));
         dispatch(sender, token, value, data);
    }

    /// @dev the real dispatcher (source: aragon)
    function dispatch(address sender, address token, uint256 value, bytes data) internal {
        // First, check permissions
        require(canProceed(sender, token, value, data));

        // Deposit the money
        deposit(token, value);

        // if there is no data, no need to parse them!
        if (data.length == 0) return;

        bytes4 sig;
        assembly { sig := mload(add(data, 0x20)) }
        var (toCall, isModule) = getFromSig(sig);
        uint32 len = RETURN_MEMORY_SIZE; // constant var not supported by inline assembly

        // For some reason, solc doesn't find the `invalidJumpLabel` identifier, so let's add one
        uint invalidJumpLabel = 0x42;

        require(toCall > 0);

        if (isModule) {
            // Save it for further use
            setMsg(sender, token, value);
            assembly {
                let result := 0
                result := delegatecall(sub(gas, 10000), toCall, add(data, 0x20), mload(data), 0, len)
                jumpi(invalidJumpLabel, iszero(result))
                return(0, len)
            }
        } else {
           IApplication(toCall).setMsg(sender, token, value);
           assembly {
                let result := 0
                result := call(sub(gas, 10000), toCall, 0, add(data, 0x20), mload(data), 0, len)
                jumpi(invalidJumpLabel, iszero(result))
                return(0, len)
           }
        }
    }

    function deposit(address token, uint256 value) internal {
        var (vault,) = getFromSig(VAULT_DEPOSIT_SIG);
        if (value == 0 || vault == 0) return;

        assert(vault.delegatecall(VAULT_DEPOSIT_SIG, token, value));
    }

    // Management functions

    /// @param newOracle address of the permissions application
    function setPermissionOracle(address newOracle) {
        setStorage(PERMISSION_ORACLE_KEY, uint256(newOracle));
    }

    function getPermissionOracle() constant returns (address oracleAddress) {
        oracleAddress = address(getStorage(PERMISSION_ORACLE_KEY));
    }

    /// @notice check permissions
    function canProceed(address sender, address token, uint256 value, bytes data) constant returns (bool) {
        address oracle = getPermissionOracle();
        if (oracle == 0) {
            // No oracle set
            return true;
        } else {
            return IPermissionOracle(oracle).isAuthorized(sender, token, value, data);
        }
    }

    /// @param module module address
    /// @param sigs array of function signatures (ordered)
    function installModule(address module, bytes4[] sigs) {
        install(module, sigs, true);
    }

    function uninstallModule(bytes4[] sigs) {
        uninstall(sigs, true);
    }

    function upgradeModule(address module, bytes4[] oldSigs, bytes4[] newSigs) {
        uninstallModule(oldSigs);
        installModule(module, newSigs);
    }

    /// @param application application address
    /// @param sigs array of function signatures (ordered)
    function installApplication(address application, bytes4[] sigs) {
        install(application, sigs, false);
    }

    function uninstallApplication(bytes4[] sigs) {
        uninstall(sigs, false);
    }

    function upgradeApplication(address application, bytes4[] oldSigs, bytes4[] newSigs) {
        uninstallApplication(oldSigs);
        installApplication(application, newSigs);
    }

    function upgradeCore(address newCore) {
        setCore(newCore);
    }

    /// @notice very sensible function, destroy the entity
    function kill() {
        address me = getThis();

        // Check if called in entity context
        assert(this == me);
        assert(me > 0);

        // Bye bye world
        selfdestruct(0x42);
    }

    // Utils to add modules or applications, mostly copied from Aragon

    /// @dev that function return the storage key associated to a signature
    function keyForSig(bytes4 sig) internal returns (bytes32) {
        return sha3(0x1, 0x1, sig); // 0x1, 0x0 already used for the permission oracle
    }

    /// @dev install a module or application
    /// @param deployed address of the contract
    /// @param sigs list of function signatures
    /// @param isModule is it called with delegatecall or just with call
    function install(address deployed, bytes4[] sigs, bool isModule) internal {
        // Save if it is a module or not (comes from the Aragon implementation)
        // if the contract is a module, a bit at "1" will be added at the beginning
        uint toAdd = isModule ? 2 ** 8 ** 20 : 0;

        setStorage(keyForSig(bytes4(sha3(sigs))), identifier(isModule));

        for (uint i = 0; i < sigs.length; i++) {
            // Can't overwrite applications signatures, unless this is a module
            require(isModule || getStorage(keyForSig(sigs[i])) == 0);

            // Sigs should be ordered
            require(i == 0 || sigs[i] > sigs[i - 1]);

            setStorage(keyForSig(sigs[i]), uint256(deployed) + toAdd);
        }
    }

    /// @dev uninstall a module or application
    /// @param sigs signature list, used to "auth" the component
    /// @param isModule is the component a module
    function uninstall(bytes4[] sigs, bool isModule) internal {
        // Check sigs and isModule parameter
        require(getStorage(keyForSig(bytes4(sha3(sigs)))) == identifier(isModule));

        // Disable the handlers
        for (uint i = 0; i < sigs.length; i++) {
            setStorage(keyForSig(sigs[i]), 0);
        }
    }

    function identifier(bool isModule) internal returns (uint) {
        return isModule ? 2 : 1;
    }

    /// @notice get an handler
    /// @param sig signature of the function we want
    /// @return component address of the contract implementing the function
    /// @return isModule if the component is a module, we need to call it via delegatecall
    function getFromSig(bytes4 sig) constant returns (address component, bool isModule) {
        uint256 data = getStorage(keyForSig(sig));
        isModule = data >> 8 * 20 == 1; // get the bit we added in "install"
        component = address(data);
    }
}
