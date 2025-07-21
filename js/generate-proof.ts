// @ts-ignore
const circuit = require("../circuits/target/noir_private_matrix_proof.json");
import { Noir } from "@noir-lang/noir_js";
import { UltraHonkBackend } from "@aztec/bb.js";
import fs from "fs";

(async () => {
  try {
    const noir = new Noir(circuit);
    const honk = new UltraHonkBackend(circuit.bytecode, { threads: 1 });

    const inputs = {
      a_flat: [1, 2, 3, 4, 5, 6],
      b_flat: [7, 8, 9, 10, 11, 12],
      c_flat: [58, 64, 139, 154]
    };

    const { witness } = await noir.execute(inputs);
    const { proof, publicInputs } = await honk.generateProof(witness, { keccak: true });

    fs.writeFileSync("../circuits/target/proof", proof);
    fs.writeFileSync("../circuits/target/public-inputs", JSON.stringify(publicInputs));

    console.log("Proof generated successfully");
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
})();