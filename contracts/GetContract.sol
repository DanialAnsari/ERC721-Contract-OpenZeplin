pragma solidity ^0.6.2;


contract A {

uint256 age;

function getAge() public view returns (uint256){
    return age;
}

function setAge(uint256 _age) public{
    age=_age;
}

}