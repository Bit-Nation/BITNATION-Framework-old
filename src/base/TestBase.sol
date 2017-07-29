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

    function testThrow(uint toTest) {
        require(1 != toTest);
    }
}

contract Mock {
    function shouldCrash() constant returns (bool) {
        return true;
    }
}

contract TestBase is DSTest {
    Base base;

    function setUp() {
        base = new Base(address(new FakeCore()));
    }

    function test_delegateIncomingCallsAndCheckSetupHasBeenDone() {
        FakeCore delegate = FakeCore(base);
        assert(delegate.didSetup() == true);
    }

    function testFail_functionThrow() {
        FakeCore delegate = FakeCore(base);
        delegate.testThrow(1);
    }

    function testFail_unknownFunction() {
        Mock mock = Mock(base);
        mock.shouldCrash();
    }
}
