pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./Core.sol";
import "../apps/permissions/IOracle.sol";
import "../base/Base.sol";
import "../apps/IApplication.sol";


contract MockPermissionOracle is IPermissionOracle {
    function isAuthorized(address sender, address token, uint256 value, bytes data) constant returns (bool) {
        return false; // just deny
    }
}

contract MockCore is Core {
    function mock() constant returns (bool) {
        return true;
    }

    // patch canProceed so it always return false
    function canProceed(address sender, address token, uint256 value, bytes data) constant returns (bool) {
        return false;
    }
}

contract MockModule {
    function module() constant returns (bool) {
        return true;
    }
}

contract MockApp is IApplication {
    bool setMsgCalled;

    function setMsg(address sender, address token, uint256 value) {
        setMsgCalled = true;
    }

    function app() constant returns (bool) {
        return setMsgCalled;
    }
}

contract TestCore is DSTest {
    Core core;

    function setUp() {
        // That line is not very clear so here is a quick explanation:
        //  -  create the base contract with its core
        //  -  then, use that contract (base) as a core one, made possible by delegating calls
        core = Core(new Base(new Core()));
    }

    function testFail_setupOnlyOnce() {
        core.setup(address(core));
    }

    function test_setAndGetPermissonOracle() {
        core.setPermissionOracle(0x42);

        assert(core.getPermissionOracle() == 0x42);
    }

    function test_canProceed() {
        // With no oracle, should return true
        assert(core.canProceed(0x42, 0x24, 0, msg.data) == true);

        // Now, our oracle make it false
        core.setPermissionOracle(new MockPermissionOracle());
        assert(!core.canProceed(0x42, 0x24, 0, msg.data));
    }

    function test_life_kill() {
        core.kill();
    }

    function test_life_upgradeNewFunction() {
        core.upgradeCore(new MockCore());
        MockCore mock = MockCore(core);

        // Add a new function
        assert(mock.mock());
    }

    function test_life_upgradeReplaceFunction() {
        core.upgradeCore(new MockCore());

        assert(!core.canProceed(0x42, 0x24, 0, msg.data));
    }

    function test_moduleUsage() {
        bytes4[] memory sigs = new bytes4[](1);
        sigs[0] = bytes4(sha3("module()"));

        // install
        core.installModule(new MockModule(), sigs);

        // use
        MockModule mock = MockModule(address(core));
        assert(mock.module());
    }

    function testFail_moduleUninstall() {
        bytes4[] memory sigs = new bytes4[](1);
        sigs[0] = bytes4(sha3("module()"));

        // install
        core.installModule(new MockModule(), sigs);
        core.uninstallModule(sigs);

        // use
        MockModule mock = MockModule(address(core));
        assert(mock.module());
    }

    function test_applicationUsage() {
        bytes4[] memory sigs = new bytes4[](1);
        sigs[0] = bytes4(sha3("app()"));

        core.installApplication(new MockApp(), sigs);

        MockApp mock = MockApp(address(core));
        assert(mock.app());
    }

    function testFail_applicationUninstall() {
        bytes4[] memory sigs = new bytes4[](1);
        sigs[0] = bytes4(sha3("app()"));

        // install
        core.installApplication(new MockApp(), sigs);
        core.uninstallModule(sigs);

        // use
        MockApp mock = MockApp(address(core));
        assert(mock.app());
    }
}
