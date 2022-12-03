// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

contract SIC is Ownable {
    struct Specialization {
        string specName;
        bool available;
        int duration;
    }

    struct Student {
        uint256 started;
        string studentName;
        string studentCNP;
        string studentSpecializationName;
        bool finished;
        bool suspended;
    }

    string public _name;
    string public _symbol;
    string public _address;
    uint256 public _deploymentDate;

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

    function addStudent(
        address studentAddress,
        string memory studentName,
        string memory studentCNP,
        string memory studentSpecializationName
    ) external onlyOwner {
        require(_specializations[studentSpecializationName].available==true, "Unknown Specialisation");
        require(studentByAddress[studentAddressByID[studentCNP]].started == 0, "Student with this CNP has already been registered");
        require(studentByAddress[studentAddress].started == 0, "Student with this address has already been registered");
        studentByAddress[studentAddress].started = block.timestamp;
        studentByAddress[studentAddress].studentName = studentName;
        studentByAddress[studentAddress].studentCNP = studentCNP;
        studentByAddress[studentAddress].studentSpecializationName = studentSpecializationName;
        studentByAddress[studentAddress].finished = false;
        studentByAddress[studentAddress].suspended = false;

        studentAddressByID[studentCNP] = studentAddress;
    }

    function studentFinished(string memory CNP) external onlyOwner {
        require(studentByAddress[studentAddressByID[CNP]].started != 0, "Non-Existing Student");
        require(studentByAddress[studentAddressByID[CNP]].suspended == false, "This student is suspended");
        require(studentByAddress[studentAddressByID[CNP]].finished == false, "This student already finished");
        studentByAddress[studentAddressByID[CNP]].finished = true;
    }

    function studentSuspended(string memory CNP) external onlyOwner {
        require(studentByAddress[studentAddressByID[CNP]].started != 0, "Non-Existing Student");
        require(studentByAddress[studentAddressByID[CNP]].suspended == false, "This student is already suspended");
        require(studentByAddress[studentAddressByID[CNP]].finished == false, "This student already finished");
        studentByAddress[studentAddressByID[CNP]].suspended = true;
    }

    function studentResmued(string memory CNP) external onlyOwner {
        require(studentByAddress[studentAddressByID[CNP]].started != 0, "Non-Existing Student");
        require(studentByAddress[studentAddressByID[CNP]].suspended == true, "This student is not suspended");
        require(studentByAddress[studentAddressByID[CNP]].finished == false, "This student already finished");
        studentByAddress[studentAddressByID[CNP]].suspended = false;
    }

    function studentChangeSpecialization(
        string memory CNP,
        string memory studentSpecializationName
    ) external onlyOwner {
        require(_specializations[studentSpecializationName].available==true, "Unknown Specialisation");
        studentByAddress[studentAddressByID[CNP]].studentSpecializationName = studentSpecializationName;
    }

    function addSpecialization(
        string memory name,
        int duration
    ) external onlyOwner {
        require(_specializations[name].available==false, "Unknown Specialisation");
        _specializations[name].specName=name;
        _specializations[name].available=true;
        _specializations[name].duration=duration;
    }

    function disableSpecialization(
        string memory name
    ) external onlyOwner {
        require(_specializations[name].available==true, "Unknown Specialisation");
        _specializations[name].available = false;
    }

    function verifyByCNP(
        string memory CNP
    ) public view returns (Student memory) {
        return studentByAddress[studentAddressByID[CNP]];
    }

    function verifyByAddress(
        address studentAddress
    ) public view returns (Student memory) {
        return studentByAddress[studentAddress];
    }
}