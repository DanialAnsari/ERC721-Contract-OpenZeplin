pragma solidity ^0.6.2;
import "./GetContract.sol";

contract B{
A public gc;

constructor(A add) public{
gc=add;
}

function getAge() public view returns(uint256){
    return gc.getAge();
}

function setAge(uint256 age) public returns(bool) {
    gc.setAge(age);
    return true;
}

}
