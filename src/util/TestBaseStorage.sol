pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "./BaseStorage.sol";


contract User is BaseStorage {
    function thisSet(address newAddr) {
        setThis(newAddr);
    }

    function coreSet(address newAddr) {
        setCore(newAddr);
    }

    function msgSet(address sender, address token, uint256 value) {
        setMsg(sender, token, value);
    }

    function msgGet() constant returns (address, address, uint256) {
        return getMsg();
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

    function test_setAndGetMsg() {
        address sender = 0x42;
        address token = 0x24;
        uint256 value = 4224;

        user.msgSet(sender, token, value);

        var (send, tok, val) = user.msgGet();

        assert(sender == send);
        assert(token == tok);
        assert(value == val);
    }
}
