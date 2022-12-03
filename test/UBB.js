const { expect } = require("chai");
const hre = require("hardhat");
const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Faculty tests:", function(){
    async function deployContract() {
        const UBB = await ethers.getContractFactory("UBB");
        const ubb = await UBB.deploy();
        const name = "Facultatea de Stiinte Economice si Gestiunea Afacerilor";
        const symbol = "FSEGA";

        await ubb.addFaculty(name, symbol);

        return { ubb, name, symbol };
    }

    it('Should be possible to add and get a faculty', async function() {

        const {ubb, name, symbol} = await loadFixture(deployContract);

        const res = await ubb.getFaculty(symbol);

        expect(res.facultyName).to.equals(name);
    });

    it('Should revert if the owner is trying to add a duplicate', async function() {

        const {ubb, name, symbol} = await loadFixture(deployContract);

        await expect(ubb.addFaculty(name, symbol)).to.be.revertedWith("This Faculty is already added to the contract.");
    });

    it('Should revert if someone else is trying to add a faculty', async function() {

        const {ubb, name, symbol} = await loadFixture(deployContract);
        const [owner, otherAccount] = await ethers.getSigners();

        await expect(ubb.connect(otherAccount).addFaculty(name, symbol)).to.be.revertedWith("Ownable: caller is not the owner");
    });

})

describe("Specialisation tests:", function(){

    async function deployContract() {
        const UBB = await ethers.getContractFactory("UBB");
        const ubb = await UBB.deploy();
        const name = "Facultatea de Stiinte Economice si Gestiunea Afacerilor";
        const symbol = "FSEGA";
        await ubb.addFaculty(name, symbol);

        const specName = "Informatica Economica";
        await ubb.addSpecializationWithFaculty(specName, 3, symbol);

        return { ubb, name, symbol, specName };
    }

    it('Should be possible to add a specialisation', async function() {

        const {ubb, symbol, specName} = await loadFixture(deployContract);

        const res = await ubb.getSpecializationWithFaculty(specName);
        const {0: specialization, 1: faculty} = res;

        expect(specialization.specName).to.equals(specName);
        expect(faculty).to.equals(symbol);
    });

    it('Should revert if the owner is trying to add a duplicate', async function() {

        const {ubb, symbol, specName} = await loadFixture(deployContract);

        await expect(ubb.addSpecializationWithFaculty(specName, 3, symbol)).to.be.revertedWith("This specialization is already added to the contract");
    });

    it('Should revert if someone else is trying to add a specialization', async function() {

        const {ubb, symbol, specName} = await loadFixture(deployContract);
        const [owner, otherAccount] = await ethers.getSigners();

        await expect(ubb.connect(otherAccount).addSpecializationWithFaculty(specName, 3, symbol)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it('Should revert if we passed a non-existing faculty to the addSpecialization', async function() {

        const {ubb} = await loadFixture(deployContract);

        await expect(ubb.addSpecializationWithFaculty("New Specialization", 3, "Non-existig")).to.be.revertedWith("Unknown Faculty");
    });

})

describe("Student tests:", function(){

    async function deployContract() {
        const UBB = await ethers.getContractFactory("UBB");
        const ubb = await UBB.deploy();
        const name = "Facultatea de Stiinte Economice si Gestiunea Afacerilor";
        const symbol = "FSEGA";
        await ubb.addFaculty(name, symbol);

        const specName = "Informatica Economica";
        await ubb.addSpecializationWithFaculty(specName, 3, symbol);

        const studName = 'Toro Etele';
        const studAddress = '0x6e33A711D62aea5a248a7035f3Cb2509146ab293';
        const studCNP = '5010324142390';
        await ubb.addStudent(studAddress, studName, studCNP, specName);

        return { ubb, name, symbol, specName, studAddress, studName, studCNP };
    }

    it('Should be possible to add a student and verify by address', async function() {

        const {ubb, studAddress, studName, studCNP} = await loadFixture(deployContract);

        const res = await ubb.verifyByAddress(studAddress);

        expect(res.studentName).to.equals(studName);
        expect(res.studentCNP).to.equals(studCNP);
    });

    it('Should be possible to verify a student by CNP', async function() {

        const {ubb, studAddress, studName, studCNP} = await loadFixture(deployContract);

        const res = await ubb.verifyByCNP(studCNP);

        expect(res.studentName).to.equals(studName);
        expect(res.studentCNP).to.equals(studCNP);
    });

    
    it('Should revert if the owner is trying to add a duplicate by CNP', async function() {

        const {ubb, specName, studAddress, studName, studCNP} = await loadFixture(deployContract);

        await expect(ubb.addStudent(studAddress, studName, studCNP, specName)).to.be.revertedWith("Student with this CNP has already been registered");
    });

    it('Should revert if the owner is trying to add a duplicate by address', async function() {

        const {ubb, specName, studAddress, studName} = await loadFixture(deployContract);
        const customCNP = 'Custom-CNP'

        await expect(ubb.addStudent(studAddress, studName, customCNP, specName)).to.be.revertedWith("Student with this address has already been registered");
    });
    
    it('Should revert if someone else is trying to add a specialization', async function() {

        const {ubb, specName, studAddress, studName, studCNP} = await loadFixture(deployContract);
        const [owner, otherAccount] = await ethers.getSigners();

        await expect(ubb.connect(otherAccount).addStudent(studAddress, studName, studCNP, specName)).to.be.revertedWith("Ownable: caller is not the owner");
    });
    
    it('Should revert if we pass a non-existing specialization for the student', async function() {

        const {ubb, studAddress, studName, studCNP} = await loadFixture(deployContract);

        await expect(ubb.addStudent(studAddress, studName, studCNP, "Non-existing")).to.be.revertedWith("Unknown Specialisation");
    });
    
})

describe("Student modifying tests:", function(){

    async function deployContract() {
        const UBB = await ethers.getContractFactory("UBB");
        const ubb = await UBB.deploy();
        const name = "Facultatea de Stiinte Economice si Gestiunea Afacerilor";
        const symbol = "FSEGA";
        await ubb.addFaculty(name, symbol);

        const specName = "Informatica Economica";
        await ubb.addSpecializationWithFaculty(specName, 3, symbol);

        const studName = 'Toro Etele';
        const studAddress = '0x6e33A711D62aea5a248a7035f3Cb2509146ab293';
        const studCNP = '5010324142390';
        await ubb.addStudent(studAddress, studName, studCNP, specName);

        return { ubb, name, symbol, specName, studAddress, studName, studCNP };
    }

    it('Should be possible to modify student finished state', async function() {

        const {ubb, studAddress, studCNP} = await loadFixture(deployContract);

        await ubb.studentFinished(studCNP)

        const res = await ubb.verifyByAddress(studAddress);

        expect(res.finished).to.equals(true);
    });

    it('Should be possible to modify student finished state', async function() {

        const {ubb, studAddress, studName, studCNP} = await loadFixture(deployContract);

        await ubb.studentSuspended(studCNP)

        const res = await ubb.verifyByAddress(studAddress);

        expect(res.suspended).to.equals(true);
    });

    it('Should revert if the owner wants to modify the finished state for a suspended student', async function() {

        const {ubb, studCNP} = await loadFixture(deployContract);

        await ubb.studentSuspended(studCNP)

        await expect(ubb.studentFinished(studCNP)).to.be.revertedWith("This student is suspended");
    });

    it('Should revert if the owner wants to modify the suspended state for a finished student', async function() {

        const {ubb, studCNP} = await loadFixture(deployContract);

        await ubb.studentFinished(studCNP)

        await expect(ubb.studentSuspended(studCNP)).to.be.revertedWith("This student already finished");
    });

    it('Should revert if the owner is trying to change the finished state of a Non-Existing student', async function() {

        const {ubb} = await loadFixture(deployContract);
        const customCNP = 'Custom-CNP'

        await expect(ubb.studentFinished(customCNP)).to.be.revertedWith("Non-Existing Student");
    });

    it('Should revert if the owner is trying to change the suspended state of a Non-Existing student', async function() {

        const {ubb, specName, studAddress, studName} = await loadFixture(deployContract);
        const customCNP = 'Custom-CNP'

        await expect(ubb.studentSuspended(customCNP)).to.be.revertedWith("Non-Existing Student");
    });

   /* 

    it('Should revert if the owner is trying to add a duplicate by address', async function() {

        const {ubb, specName, studAddress, studName} = await loadFixture(deployContract);
        const customCNP = 'Custom-CNP'

        await expect(ubb.addStudent(studAddress, studName, customCNP, specName)).to.be.revertedWith("Student with this address has already been registered");
    });
    
    it('Should revert if someone else is trying to add a specialization', async function() {

        const {ubb, specName, studAddress, studName, studCNP} = await loadFixture(deployContract);
        const [owner, otherAccount] = await ethers.getSigners();

        await expect(ubb.connect(otherAccount).addStudent(studAddress, studName, studCNP, specName)).to.be.revertedWith("Ownable: caller is not the owner");
    });
    
    it('Should revert if we pass a non-existing specialization for the student', async function() {

        const {ubb, studAddress, studName, studCNP} = await loadFixture(deployContract);

        await expect(ubb.addStudent(studAddress, studName, studCNP, "Non-existing")).to.be.revertedWith("Unknown Specialisation");
    });
   */ 
})
