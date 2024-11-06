// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JohnToken {
    string public name = "JohnToken";   // Token name
    string public symbol = "JT";        // Token symbol
    uint8 public decimals = 12;         // Decimal places
    uint256 public totalSupply = 1000000000000000000000; // Initial supply (with decimals)
    address public owner;               // Owner address

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value); // Event for minting new tokens

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;  // Set the owner to the contract deployer
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Mint function to create new tokens and assign them to a specific address
    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        totalSupply += _value;              // Increase total supply
        balanceOf[_to] += _value;           // Add the minted tokens to the specified address
        emit Mint(_to, _value);             // Emit the mint event
        emit Transfer(address(0), _to, _value);  // Emit the transfer event (from 0 address for minting)
        return true;
    }
}
