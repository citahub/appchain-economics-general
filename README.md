# CITA AppChain Economics Contracts- README
## Overview
CITA system contracts can set a contract to be executed automatically for each block, so the system's economic rules can be contracted through this automatically executed action. Economic rules include: block reward rules, transaction fee rules, and so on. The main function of this economic model framework is to give a basic block reward and transaction fee rules, and to allow rules to be modified through governance mechanisms.

![经济模型英文.png](https://note.youdao.com/yws/res/493/WEBRESOURCE2c02bce52e957e7d4a2aa227aeeb0dbf)

The specific implementation method is as follows: after the system authority is transferred to the governance contract, the TokenLock contract is used to transfer the specified proportion of the pre-allocated block reward to the Finance contract. The Finance contract is set to be automatically executed for each block, and the block reward and transaction fees are allocated for each block. Thus, the governance contract can change the distribution of block reward and transaction fees by modifying the Finance contract.

## Process for deploying an economic model
Generation transaction
- Set up the basic transaction management model (charge = 1), the block reward is returned to the consensus node by default, but the operator can return the block reward to himself by setting checkFeeBackPlatform and chainOwner.
- Set up the total supply and basic information of tokens

Token pre-allocation
-  Assign tokens to various stakeholders according to predetermined rules by  super_admin account

Transfer of governance
- Remove the system's super_admin privilege and pass it to the governance contract

Economic model contract take effect
- Add the economic model contract to the system auto-execution contract list
 
Autonomous stage
- According to the rules in the economic model contract, each block automatically generate ablock reward

## Introduction to economic model contracts
### Finance contract
- Transfer the specified proportion of the total number of remaining NATTs  to coinbase
- Transfer tokens to the specified address, if it is 0 address, destroy tokens.
- If the address is not a 0 address, transfer tokens to the specified address.

```JavaScript
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
```
### TokenLock
Transfer the specified proportion of NATTs  to the Finance contract and foundation address
```JavaScript
// transfer to foundationAddr
        _transfer(foundationAddr, _totalSupply * foundationPortion / totalPortion);
        // transfer to finAddr
        _transfer(finAddr, _totalSupply * miningPortion / totalPortion);
```
Average release of tokens to presaleAddrs on a specified number of times
```JavaScript
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
```
Average release of tokens to teamAddr on a specified number of times
```JavaScript
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
```