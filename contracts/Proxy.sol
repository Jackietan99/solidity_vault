// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract TestContract1 {
    address public owner = msg.sender;

    function setOwner(address _owner) public {
        require(msg.sender == owner, "not the owner");
        owner = _owner;
    }
}

contract TestContract2 {
    address public owner = msg.sender;
    uint public value = msg.value;
    uint public x;
    uint public y;

    constructor(uint _x, uint _y) payable {
        x = _x;
        y = _y;
    }
}

contract Proxy {
    event Deploy(address);

    function deploy(bytes memory _code)
        external
        payable
        returns (address addr)
    {
        assembly {
            //create(v , p , n)
            // v = amount of eth to send
            // p = pointer in memory to start the code
            // n = size of code

            addr := create(callvalue(), add(_code, 0x20), mload(_code))
        }
        require(addr != address(0), "deploy failed");
        emit Deploy(addr);
    }

    function execute(address _target, bytes memory _data) external payable {
        (bool success, ) = _target.call{value: msg.value}(_data);
        require(success, "execute failed");
    }
}

contract helper {
    function getByteCode1() external pure returns (bytes memory) {
        bytes memory byteCode = type(TestContract1).creationCode;
        return byteCode;
    }

    function getByteCode2(uint _x, uint _y)
        external
        pure
        returns (bytes memory)
    {
        bytes memory byteCode = type(TestContract2).creationCode;
        return abi.encodePacked(byteCode, abi.encode(_x, _y));
    }

    function getCallData(address _owner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("setOwner(address)", _owner);
    }
}
