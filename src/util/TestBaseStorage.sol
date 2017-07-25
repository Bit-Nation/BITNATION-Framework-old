pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "./BaseStorage.sol";


contract User is BaseStorage {
    function thisSet(address newAddr) {
        super.setThis(newAddr);
    }

    function coreSet(address newAddr) {
        super.setCore(newAddr);
    }
}

contract TestBaseStorage is DSTest {
    User user;

    function setUp() {
        user = new User();
    }

    function test_setAndGetThis() {
        user.thisSet(0x42);
        assert(user.getThis() == 0x42);
    }

    function test_setAndGetCore() {
        user.coreSet(0x42);
        assert(user.getCore() == 0x42);
    }
}
