// truffle.d.ts
import {Contract} from "web3";

declare global {
    let artifacts: Artifacts;
    let contract: ContractTest;
}


interface TestCallback {
    (accounts: number[]): void
}

interface ContractTest {
    (description: string, callback: TestCallback): void
}

interface Artifacts {
    require(name: "GameSettings"): Contract<any>;
}