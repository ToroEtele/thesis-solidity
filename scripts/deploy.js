// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
import { ethers } from "hardhat";

async function main() {
  const UBB = await ethers.getContractFactory("UBB");
  const ubb = await UBB.deploy();

  await ubb.deployed();

  console.log(
    `Contract deployed to ${ubb.address}`
  );

  const name = "Facultatea de Stiinte Economice si Gestiunea Afacerilor";
  const symbol = "FSEGA";
  await ubb.addFaculty(name, symbol);

  const specName = "Informatica Economica";
  await ubb.addSpecializationWithFaculty(specName, 3, symbol);

  const studName = 'Toro Etele';
  const studAddress = '0x6e33A711D62aea5a248a7035f3Cb2509146ab293';
  const studCNP = '5010324142390';
  await ubb.addStudent(studAddress, studName, studCNP, specName);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
