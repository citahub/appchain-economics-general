pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract TokenLock {
    using SafeMath for uint256;
    using SafeMath for uint8;
    
    // time
    uint256 public timeSpan = 30 days;
    uint256 public startTime;
    
    // Percentage
    uint8 public totalPortion = 100;
    // Set presale percent to 10%;
    uint8 public presalePortion = 10;
    // Set team reserve to 15%;
    uint8 public teamReservePortion = 15;
    // Set foundation to 10%;
    uint8 public foundationPortion = 10;
    // Set mining to 65%;
    uint8 public miningPortion = 65;
    
    // stakeholder
    address public teamAddr;
    address public foundationAddr;
    address public finAddr;
    address[] public presaleAddrs;
    
    // token
    uint256 private _totalSupply = msg.value;
    
    // unlock
    uint8 public maxRounds = 3;
    uint8 public presaleUnlockRounds = 0;
    uint8 public teamReserveUnlockRounds = 0;

    event Init(address indexed from, uint indexed value, address[] presaleAddrs, address teamAddr, address finAddr);
    event Transfer(address indexed from, address indexed to, uint indexed value);
    
    constructor(
        address[] _presaleAddrs, 
        address _teamAddr, 
        address _foundationAddr, 
        address _finAddr,
        uint256 _startTime
    ) public payable {
        teamAddr = _teamAddr;
        foundationAddr = _foundationAddr;
        finAddr = _finAddr;
        for(uint8 i = 0; i < _presaleAddrs.length; i++) {
            presaleAddrs.push(_presaleAddrs[i]);
        }
        startTime = _startTime;
        // transfer to foundationAddr
        _transfer(foundationAddr, _totalSupply * foundationPortion / totalPortion);
        // transfer to finAddr
        _transfer(finAddr, _totalSupply * miningPortion / totalPortion);
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    modifier specifiedRound(uint8 _round) {
        require(_round < maxRounds, "Invalid Round");
        _;
    }
    
    // modifier specifiedTime(uint256 _currentTime, uint8 _round, uint256 _timeSpan) {
    //     require(_currentTime >= uint256(_round + 1).mul(_timeSpan).add(startTime), "Invalid Time");
    //     _;
    // }
    
    function unlockPresale()
    public 
    specifiedRound(presaleUnlockRounds)
    // specifiedTime(block.timestamp, presaleUnlockRounds, timeSpan)
    returns (uint256 _token)
    {
        presaleUnlockRounds = presaleUnlockRounds + 1;
        uint256 token = _totalSupply * presalePortion / maxRounds / totalPortion / presaleAddrs.length;
        for (uint8 i = 0; i < presaleAddrs.length; i++) {
            _transfer(presaleAddrs[i], token);
        }
        return token;
    }

    function unlockTeamReserve()
    public
    specifiedRound(teamReserveUnlockRounds)
    // specifiedTime(block.timestamp, teamReserveUnlockRounds, 2 * timeSpan)
    returns (uint256 _token)
    {
        teamReserveUnlockRounds = teamReserveUnlockRounds + 1;
        uint256 token = _totalSupply * teamReservePortion / maxRounds / totalPortion;
        _transfer(teamAddr, token);
        return token;
    }
    
    function _transfer(address _to, uint256 _value) internal returns (bool) {
        require(address(this).balance >= _value, "Balance not enough");
        require(_to != address(0), "Invalid Addres");
        _to.transfer(_value);
        emit Transfer(this, _to, _value);
    }
}
