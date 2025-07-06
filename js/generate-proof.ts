import { UltraHonkBackend } from "@aztec/bb.js";
import fs from "fs";
import path from "path";
import circuit from "../circuits/target/zkp_pedersen_range_safe.json";
// @ts-ignore
import { Noir } from "@noir-lang/noir_js";

(async () => {
  try {
    const noir = new Noir(circuit as any);
    const honk = new UltraHonkBackend(circuit.bytecode, { threads: 1 });

    const inputs = {
      message: 10,
      blinding: 7,
      g: 5,
      h: 3,
      commitment: 21357421875,
      min_bound: 5,
      max_bound: 15,
      strict_range: false,
      require_positive_blinding: false
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