pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "./Base.sol";
import "../util/BaseStorage.sol";
import "../core/ICore.sol";


contract FakeCore is ICore, BaseStorage {
    function setup(address baseCoreAddr) {
        setStorage(sha3(0x1, 0x42), 1);
    }

    function didSetup() returns (bool) {
        return getStorage(sha3(0x1, 0x42)) == 1;
    }
}

contract TestBase is DSTest {
    Base base;
    FakeCore core;

    function setUp() {
        core = new FakeCore();
        base = new Base(core);
    }

    function test_setupShouldBeCalled() {
        assert(core.didSetup() == true);
    }

    function test_delegateIncomingCalls() {
        FakeCore delegate = FakeCore(base);
        assert(core.didSetup() == true);
    }
}
