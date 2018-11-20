pragma solidity ^0.4.24;


contract Finance {

    address private _owner = msg.sender;
    address public fallbackAddr;
    
    uint256 ratio = 300;

    event Transfer(address indexed from, address indexed to, uint256 indexed value);
    event Burn(uint indexed value);

    modifier onlyOwner {
        require(msg.sender == _owner, "Owner Required");
        _;
    }

    constructor (address _fallbackAddr) public {
        fallbackAddr = _fallbackAddr;
    }

    function incentive() private {
        _transfer(address(block.coinbase), address(this).balance/ratio);
    }

    function burn(uint value) public onlyOwner returns (bool) {
        _transfer(fallbackAddr, value);
    }

    function _transfer(address to, uint value) private returns (bool) {
        require(to != address(0), "Invalid Address");
        to.transfer(value);
        emit Transfer(address(this), to, value);
    }
}
