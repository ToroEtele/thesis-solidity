// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

contract SIC is Ownable {
    struct Specialization {
        string specName;
        bool available;
        int256 duration;
    }

    struct Student {
        uint256 started;
        string studentName;
        string studentCNP;
        string studentSpecializationName;
        bool finished;
        bool suspended;
    }

    string _name;
    string _symbol;
    string _address;
    uint256 _deploymentDate;

    mapping(address => Student) studentByAddress;
    mapping(string => address) studentAddressByID;
    mapping(string => Specialization) _specializations;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory address_
    ) {
        _name = name_;
        _symbol = symbol_;
        _address = address_;
        _deploymentDate = block.timestamp;
    }

    // Students related methods:

    function addStudent(
        address studentAddress,
        string memory studentName,
        string memory studentCNP,
        string memory studentSpecializationName
    ) external onlyOwner {
        require(
            _specializations[studentSpecializationName].available == true,
            "Unknown Specialisation"
        );
        require(
            studentByAddress[studentAddressByID[studentCNP]].started == 0,
            "Student with this CNP has already been registered"
        );
        require(
            studentByAddress[studentAddress].started == 0,
            "Student with this address has already been registered"
        );
        studentByAddress[studentAddress].started = block.timestamp;
        studentByAddress[studentAddress].studentName = studentName;
        studentByAddress[studentAddress].studentCNP = studentCNP;
        studentByAddress[studentAddress]
            .studentSpecializationName = studentSpecializationName;
        studentByAddress[studentAddress].finished = false;
        studentByAddress[studentAddress].suspended = false;

        studentAddressByID[studentCNP] = studentAddress;
    }

    function studentFinished(string memory CNP) external onlyOwner {
        require(
            studentByAddress[studentAddressByID[CNP]].started != 0,
            "Non-Existing Student"
        );
        require(
            studentByAddress[studentAddressByID[CNP]].suspended == false,
            "This student is suspended"
        );
        require(
            studentByAddress[studentAddressByID[CNP]].finished == false,
            "This student already finished"
        );
        studentByAddress[studentAddressByID[CNP]].finished = true;
    }

    function studentSuspended(string memory CNP) external onlyOwner {
        require(
            studentByAddress[studentAddressByID[CNP]].started != 0,
            "Non-Existing Student"
        );
        require(
            studentByAddress[studentAddressByID[CNP]].suspended == false,
            "This student is already suspended"
        );
        require(
            studentByAddress[studentAddressByID[CNP]].finished == false,
            "This student already finished"
        );
        studentByAddress[studentAddressByID[CNP]].suspended = true;
    }

    function studentResumed(string memory CNP) external onlyOwner {
        require(
            studentByAddress[studentAddressByID[CNP]].started != 0,
            "Non-Existing Student"
        );
        require(
            studentByAddress[studentAddressByID[CNP]].suspended == true,
            "This student is not suspended"
        );
        studentByAddress[studentAddressByID[CNP]].suspended = false;
    }

    function studentChangeSpecialization(
        string memory studCNP,
        string memory studentSpecializationName
    ) external onlyOwner {
        require(
            _specializations[studentSpecializationName].available == true,
            "Unknown Specialisation"
        );
        require(
            studentByAddress[studentAddressByID[studCNP]].started != 0,
            "Non-Existing Student"
        );
        studentByAddress[studentAddressByID[studCNP]]
            .studentSpecializationName = studentSpecializationName;
    }

    function studentChangeAddress(
        address studentOldAddress,
        address studentNewAddress,
        string memory studentCNP
    ) external onlyOwner {
        require(
            studentByAddress[studentOldAddress].started != 0,
            "Non-Existing Student"
        );
        require(
            studentAddressByID[studentCNP] == studentOldAddress,
            "Non-Existing old address and CNP combination"
        );

        studentByAddress[studentOldAddress].suspended = true;
        studentByAddress[studentNewAddress] = studentByAddress[
            studentOldAddress
        ];
        studentAddressByID[studentCNP] = studentNewAddress;
        studentByAddress[studentNewAddress].suspended = false;
    }

    // Specializations related methods:

    function addSpecialization(string memory name, int256 duration)
        external
        onlyOwner
    {
        require(
            _specializations[name].available == false,
            "Unknown Specialisation"
        );
        _specializations[name].specName = name;
        _specializations[name].available = true;
        _specializations[name].duration = duration;
    }

    function getSpecialization(string memory specName)
        external
        view
        returns (Specialization memory)
    {
        return _specializations[specName];
    }

    function disableSpecialization(string memory name) external onlyOwner {
        require(
            _specializations[name].available == true,
            "Specialization is not available"
        );
        _specializations[name].available = false;
    }

    function enableSpecialization(string memory name) external onlyOwner {
        require(
            _specializations[name].duration != 0,
            "Non-Existent Specilaization"
        );
        require(
            _specializations[name].available == false,
            "Specilaization already enabled"
        );
        _specializations[name].available = true;
    }

    // Verifying students methods:

    function verifyByCNP(string memory studCNP)
        public
        view
        returns (Student memory)
    {
        require(
            studentByAddress[studentAddressByID[studCNP]].started != 0,
            "Non-Existing Student"
        );
        return studentByAddress[studentAddressByID[studCNP]];
    }

    function verifyByAddress(address studentAddress)
        public
        view
        returns (Student memory)
    {
        require(
            studentByAddress[studentAddress].started != 0,
            "Non-Existing Student"
        );
        return studentByAddress[studentAddress];
    }

    function getAddressByID(string memory studCNP)
        public
        view
        returns (address)
    {
        require(
            studentAddressByID[studCNP] != address(0),
            "This CNP does not have an associated address"
        );
        return studentAddressByID[studCNP];
    }

    function getUniversityInfo()
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            uint256
        )
    {
        return (_name, _symbol, _address, _deploymentDate);
    }
}
