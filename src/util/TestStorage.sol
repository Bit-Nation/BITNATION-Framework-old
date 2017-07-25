pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "./Storage.sol";


contract TestStorage is DSTest {
    Storage store;

    function setUp() {
        store = new Storage();
    }

    function testFail_setAndGetValueShouldNotBeAvailable() {
        store.setStorage(0x1, 42);
        assert(store.getStorage(0x1) == 42);
    }
}
