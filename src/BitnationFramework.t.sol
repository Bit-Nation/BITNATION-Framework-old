pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./BitnationFramework.sol";

contract BitnationFrameworkTest is DSTest {
    BitnationFramework framework;

    function setUp() {
        framework = new BitnationFramework();
    }

    function testFail_basic_sanity() {
        assert(false);
    }

    function test_basic_sanity() {
        assert(true);
    }
}
