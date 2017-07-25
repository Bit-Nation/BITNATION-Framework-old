pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "./Storage.sol";


contract FakeStorage is Storage {
    function set(bytes32 key, uint256 value) {
        setStorage(key, value);
    }

    function get(bytes32 key) returns (uint256 value) {
        return getStorage(key);
    }
}

contract TestStorage is DSTest {
    FakeStorage store;

    function setUp() {
        store = new FakeStorage();
    }

    function test_setAndGetValue() {
        store.set(0x1, 42);
        assert(store.get(0x1) == 42);
    }
}
