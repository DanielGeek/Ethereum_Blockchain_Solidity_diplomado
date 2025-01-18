// Import

// You can import local and external files in Solidity.

// Local
// Here is our folder structure.

// ├── Import.sol
// └── Imported.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import Imported.sol from current directory
import "./46-Imported.sol";

// import {symbol1 as alias, symbol2} from "filename";
import {Unauthorized, add as func, Point} from "./46-Imported.sol";

contract Import {
    // Initialize Foo.sol
    Imported public imported = new Imported();

    // Test 46-Imported.sol by getting its name.
    function getImportedName() public view returns (string memory) {
        return imported.name();
    }
}


// External
// You can also import from GitHub by simply copying the url

// https://github.com/owner/repo/blob/branch/path/to/Contract.sol
// import "https://github.com/owner/repo/blob/branch/path/to/Contract.sol";

// Example import ECDSA.sol from openzeppelin-contract repo, release-v4.5 branch
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";
