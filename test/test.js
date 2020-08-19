const { accounts, contract } = require('@openzeppelin/test-environment');
const {expect}=require('chai');
const { isTopic } = require('web3-utils')
const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const ERC721 = contract.fromArtifact('ERC721');
const zeroAddress="0x0000000000000000000000000000000000000000";
let token
let token2,  token2Add

describe('TransferFrom', function () {
  const [owner, other] =  accounts;
  before(async function () {
    // The bundled BN library is the same one web3 uses under the hood
    

     token = await ERC721.new();

     token2 = await ERC721.new();
     //console.log("Token#2 ",token2.address)
     token2Add = token2.address
  });

  it('Making sure balance of owner is being updated on token being minted', async function () {
    // Store a value - recall that only the owner account can do this!
    await token.mint("Dan Token", { from: owner });
    expect((await token.balanceOf(owner)).toString()).to.equal('1');
  });

  it('Making owner is being assinged to token being minted', async function () {
    // Store a value - recall that only the owner account can do this!
    await token.mint("Dan Token", { from: owner });

    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    expect((await token.ownerOf(0)).toString()).to.equal(owner);
  });

  it("Confirming that token is being transferd to recipient sucessfully", async function(){
      await token.mint("Dan Token",{from: owner});
      await token.safeTransferFrom(owner,accounts[1],0,{from: owner});

      expect((await token.ownerOf(0)).toString()).to.equal(accounts[1]);
  })


  it('reverts when transferring tokens to the zero address', async function () {
    // Conditions that trigger a require statement can be precisely tested
    await expectRevert(
      token.safeTransferFrom(zeroAddress,zeroAddress,0,{from:owner}),
      'Cannot sent to zero address'
    );
  });


    it("Confirming that transfer is failing when transfer is called from non owner and non approved account", async () => {

            await expectRevert(
       token.safeTransferFrom(accounts[1],accounts[5],0,{from:accounts[3]}),
                'Only owner or approved addresses can transfer this token');
                
      })

  



  it("Confirming that a token that does not exists is not able to be transfered", async () => {

    await expectRevert(
token.safeTransferFrom(accounts[1],accounts[5],10,{from:accounts[3]}),
        'From account must be owner of token');
        
})

it("Checking whether a token can be transferd to a contract address", async () =>{
        
    
    await expectRevert(
        token.safeTransferFrom(accounts[1],token2Add,0,{from:accounts[1]}),
                'Address cannot be send to a contract address');
})

})

describe('Approve Function', function (){
    it("Checking that account is being approved", async function(){
         await token.mint("Dan Token", { from: accounts[1] });
         await token.approve(accounts[4],0,{from: accounts[1]});
         expect((await token.getApproved(0)).toString()).to.equal(accounts[4].toString());
     })
 
     it("Checking whether approved address is able to transfer token", async () =>{
         
         await token.safeTransferFrom(accounts[1],accounts[5],0,{from:accounts[4]})
 
         expect((await token.ownerOf(0)).toString()).to.equal(accounts[5]);
   })
 })

 describe('Approve For All Function', function (){
    it("Checking whether An address is being approved for for all tokens", async() =>{
        await token.setApprovalForAll(accounts[1],true,{from:accounts[5]});

        expect((await token.isApprovedForAll(accounts[5],accounts[1]))).to.equal(true)
    })

    it("Checking whether approved for all address is able to transfer token", async () =>{
      
      await token.safeTransferFrom(accounts[5],accounts[2],0,{from:accounts[1]})

      expect((await token.ownerOf(0)).toString()).to.equal(accounts[2]);
})

 })