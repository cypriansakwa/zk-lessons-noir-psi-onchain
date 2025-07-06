import { UltraHonkBackend } from "@aztec/bb.js";
import fs from "fs";
import path from "path";
import circuit from "../circuits/target/noir_pedersen_bits16.json";
// @ts-ignore
import { Noir } from "@noir-lang/noir_js";

(async () => {
  try {
    const noir = new Noir(circuit as any);
    const honk = new UltraHonkBackend(circuit.bytecode, { threads: 1 });

    const inputs = {
      x_bits: [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
      r_bits: [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      g: 2,
      h: 3, 
      C: 69984 
     };

    const { witness } = await noir.execute(inputs);
    const { proof, publicInputs } = await honk.generateProof(witness, {
      keccak: true,
    });

      // save proof to file
    fs.writeFileSync("../circuits/target/proof", proof);

    // not really needed as we harcode the public input in the contract test
    fs.writeFileSync(
      "../circuits/target/public-inputs",
      JSON.stringify(publicInputs),
    );

    console.log("Proof generated successfully");

    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
})();