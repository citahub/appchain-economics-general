const TokenLock = artifacts.require('TokenLock')

const TOTAL_SUPPLY = web3.toWei(10, 'ether')
const BASE_BALANCE = 100000000000000000000

const RATIO = {
  presale: 0.1,
  team: 0.15,
  foundation: 0.1,
  fin: 0.65,
}
const maxRounds = 3
const RevertError = 'Error: VM Exception while processing transaction: revert'

const getBalance = addrs =>
  Promise.all(
    Object.values(addrs).map(group =>
      Array.isArray(group) ? Promise.all(group.map(web3.eth.getBalance)) : web3.eth.getBalance(group),
    ),
  )

const logBalance = balances => {
  console.log(`
  ======================== Balance ========================
  Me: ${balances[0].toString()}
  Presales: ${balances[1].toString()}
  Team: ${balances[2].toString()}
  Foundation: ${balances[3].toString()}
  Fin: ${balances[4].toString()}
  `)
}

const assertBalance = (balances, expects) => {
  assert.equal(balances[1][0].toString(), expects.presale, `Balance of Presale 1 should be ${expects.presale}`)
  assert.equal(balances[1][1].toString(), expects.presale, `Balance of Presale 2 should be ${expects.presale}`)
  assert.equal(balances[2].toString(), expects.team, `Balance of Team should be ${expects.team}`)
  assert.equal(balances[3].toString(), expects.foundation, `Balance of Foundation should be ${expects.foundation}`)
  assert.equal(balances[4].toString(), expects.fin, `Balance of Fin should be ${expects.fin}`)
}

contract('TokenLock', async accounts => {
  const addrs = {
    admin: accounts[0],
    presaleAddrs: accounts.slice(1, 3),
    teamAddr: accounts[3],
    foundationAddr: accounts[4],
    finAddr: accounts[5],
  }
  const expects = {
    presale: BASE_BALANCE,
    team: BASE_BALANCE,
    foundation: (+BASE_BALANCE + RATIO.foundation * TOTAL_SUPPLY).toString(),
    fin: (+BASE_BALANCE + RATIO.fin * TOTAL_SUPPLY).toString(),
  }

  it(`When init, ${RATIO * 100}% to ${addrs.foundationAddr} and ${RATIO * 100}% to ${addrs.finAddr}`, async () => {
    const balancesAfterDeploy = await getBalance(addrs)
    logBalance(balancesAfterDeploy)

    assertBalance(balancesAfterDeploy, expects)
  })

  const presaleQuota = (RATIO.presale * TOTAL_SUPPLY) / maxRounds / addrs.presaleAddrs.length

  for (let i = 0; i < 3; i++) {
    it(`shoud send ${presaleQuota} to Presale when unlock presale at ${i + 1} release`, async () => {
      const ins = await TokenLock.deployed()
      const { logs } = await ins.unlockPresale()
      assert.deepEqual(
        {
          to: logs[0].args.to,
          value: logs[0].args.value.toString().slice(0, -1),
        },
        {
          to: addrs.presaleAddrs[0],
          value: presaleQuota.toString().slice(0, -1),
        },
      )
    })
  }
  it(`no more presale to unlock`, async () => {
    const ins = await TokenLock.deployed()
    const err = await ins.unlockPresale().catch(err => err.toString())
    assert.equal(err, RevertError)
  })

  const teamReserveQuota = (RATIO.team * TOTAL_SUPPLY) / maxRounds
  for (let i = 0; i < 3; i++) {
    it(`shoud send ${teamReserveQuota} to Presale when unlock team reserve on first time`, async () => {
      const ins = await TokenLock.deployed()
      const { logs } = await ins.unlockTeamReserve()
      assert.deepEqual(
        {
          to: logs[0].args.to,
          value: logs[0].args.value.toString().slice(0, -1),
        },
        {
          to: addrs.teamAddr,
          value: teamReserveQuota.toString().slice(0, -1),
        },
      )
    })
  }

  it('no more team reserve to unlock', async () => {
    const ins = await TokenLock.deployed()
    const err = await ins.unlockTeamReserve().catch(err => err.toString())
    assert.equal(err, RevertError)
  })
})
