pragma solidity 0.4.18;

contract KnowsTime {
    function currentTime() view public returns (uint) {
        return now;
    }
}
