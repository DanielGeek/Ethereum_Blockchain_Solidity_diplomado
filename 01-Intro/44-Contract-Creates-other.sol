// Contract that Creates other Contracts

// Contracts can be created by other contracts using the new keyword. Since 0.8.0, 
// new keyword supports create2 feature by specifying salt options.


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Car {
    address public owner;
    string public model;
    address public carAddr;

    constructor(address _owner, string memory _model) payable {
        owner = _owner;
        model = _model;
        carAddr = address(this);
    }
}

contract CarFactory {
    Car[] public cars;

    function create(address _owner, string memory _model) public {
        Car car = new Car(_owner, _model);
        cars.push(car);
    }

    function createAndSendEther(address _owner, string memory _model)
        public
        payable
    {
        Car car = (new Car){value: msg.value}(_owner, _model);
        cars.push(car);
    }

    // _owner: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // _model: "Tesla Model S"
    // _salt: 0x0000000000000000000000000000000000000000000000000000000000000000

    function create2(address _owner, string memory _model, bytes32 _salt)
        public
    {
        Car car = (new Car){salt: _salt}(_owner, _model);
        cars.push(car);
    }

    function create2AndSendEther(
        address _owner,
        string memory _model,
        bytes32 _salt
    ) public payable {
        Car car = (new Car){value: msg.value, salt: _salt}(_owner, _model);
        cars.push(car);
    }

    function getCar(uint256 _index)
        public
        view
        returns (
            address owner,
            string memory model,
            address carAddr,
            uint256 balance
        )
    {
        Car car = cars[_index];

        return (car.owner(), car.model(), car.carAddr(), address(car).balance);
    }
}
