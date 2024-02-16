// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

error SeedTooShort();

contract Coinflip is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    string public seed;

    function initialize() initializer public {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    function userInput(uint8[10] calldata Guesses) external view returns(bool){
        uint8[10] memory generatedFlips = getFlips();
        for(uint i = 0; i < 10; i++){
            if(Guesses[i] != generatedFlips[i]){
                return false;
            }
        }
        return true;
    }

    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory stringToBytes = bytes(NewSeed);
        uint seedlength = stringToBytes.length;
        if (seedlength < 10){
            revert SeedTooShort();
        }
        
        seed = NewSeed;
    }

    function getFlips() public view returns(uint8[10] memory){
        bytes memory stringToBytes = bytes(seed);
        uint seedlength = stringToBytes.length;
        uint8[10] memory results_array;

        uint interval = seedlength / 10;

        for (uint i = 0; i < 10; i++){
            uint randomNum = uint(keccak256(abi.encode(stringToBytes[i*interval], block.timestamp)));
            results_array[i] = randomNum % 2 == 0 ? 1 : 0;
        }

        return results_array;
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}
