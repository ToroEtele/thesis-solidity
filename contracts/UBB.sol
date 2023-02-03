// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SIC.sol";

contract UBB is SIC {
    struct Faculty {
        string facultyName;
        string facultySymbol;
        uint256 foundationDate;
    }

    mapping(string => Faculty) _faculties;
    mapping(string => string) _specializationToFaculty;

    constructor()
        SIC("Universitatea Babes Bolyai", "UBB", "Mihai Kogalniceanul 5.")
    {}

    function addFaculty(string memory name, string memory symbol)
        external
        onlyOwner
    {
        require(
            _faculties[symbol].foundationDate == 0,
            "This Faculty is already added to the contract."
        );
        _faculties[symbol].facultyName = name;
        _faculties[symbol].facultySymbol = symbol;
        _faculties[symbol].foundationDate = block.timestamp;
    }

    function addSpecializationWithFaculty(
        string memory specName,
        int256 duration,
        string memory faculty
    ) external onlyOwner {
        require(
            _specializations[specName].available == false,
            "This specialization is already added to the contract"
        );
        require(_faculties[faculty].foundationDate != 0, "Unknown Faculty");
        _specializations[specName].specName = specName;
        _specializations[specName].available = true;
        _specializations[specName].duration = duration;

        _specializationToFaculty[specName] = faculty;
    }

    function getFaculty(string memory symbol)
        external
        view
        returns (Faculty memory)
    {
        return _faculties[symbol];
    }

    function getSpecializationWithFaculty(string memory specName)
        external
        view
        returns (Specialization memory, string memory)
    {
        return (_specializations[specName], _specializationToFaculty[specName]);
    }
}
