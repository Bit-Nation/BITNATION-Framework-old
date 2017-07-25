pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "./BaseStorage.sol";


contract User is BaseStorage {
    function setThis(address newAddr) {
        super.setThis(newAddr);
    }

    function setCore(address newAddr) {
        super.setCore(newAddr);
    }
}

contract TestBaseStorage is DSTest {
    User store;

    function setUp() {
        store = new User();
    }

    function test_setAndGetThis() {
        user.setThis(0x42);
        assert(user.getThis() == 0x42);
    }

    function test_setAndGetCore() {
        user.setCore(0x42);
        assert(user.getCore() == 0x42);
    }
}
