// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {Token} from "src/token/Token.sol";

contract DeployScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (Token c) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address param = msg.sender;

        vm.startBroadcast(deployerPrivateKey);

        c = Token(
            create3.deploy(
                getCreate3ContractSalt("Token"), bytes.concat(type(Token).creationCode, abi.encode(param))
            )
        );

        vm.stopBroadcast();
    }
}