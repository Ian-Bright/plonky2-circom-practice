use anyhow::Result;
use plonky2::{
    field::extension::Extendable,
    gates::noop::NoopGate,
    hash::hash_types::RichField,
    iop::{
        target::Target,
        witness::{PartialWitness, WitnessWrite},
    },
    plonk::{
        circuit_builder::CircuitBuilder,
        circuit_data::{CircuitConfig, CommonCircuitData, VerifierOnlyCircuitData},
        config::{GenericConfig, PoseidonGoldilocksConfig},
        proof::ProofWithPublicInputs,
    },
};

use serde::Serialize;
use std::fs::File;
use std::io::Write;
use std::path::Path;

use plonky2_circom_verifier::verifier::{
    generate_circom_verifier, generate_proof_base64, generate_verifier_config,
};

fn make_proof<F: RichField + Extendable<D>, C: GenericConfig<D, F = F>, const D: usize>() -> Result<
    (
        ProofWithPublicInputs<F, C, D>,
        VerifierOnlyCircuitData<C, D>,
        CommonCircuitData<F, D>,
    ),
>
where
    [(); 32]:,
{
    let config = CircuitConfig::standard_recursion_config();

    let mut builder = CircuitBuilder::<F, D>::new(config.clone());

    for _ in 0..4000 {
        builder.add_gate(NoopGate, vec![]);
    }

    let x_t: Target = builder.add_virtual_target();
    let y_t: Target = builder.add_virtual_target();

    builder.connect(x_t, y_t);
    let data = builder.build::<C>();
    let mut pw = PartialWitness::<F>::new();
    pw.set_target(x_t, F::from_canonical_u64(1310));
    pw.set_target(y_t, F::from_canonical_u64(1310));
    let proof = data.prove(pw)?;
    let conf = generate_verifier_config(&proof)?;
    let (circom_constants, circom_gates) =
        generate_circom_verifier(&conf, &data.common, &data.verifier_only)?;
    let mut circom_file = File::create("./circom/circuits/constants.circom")?;
    circom_file.write_all(circom_constants.as_bytes())?;
    let mut circom_file_two = File::create("./circom/circuits/gates.circom")?;
    circom_file_two.write_all(circom_gates.as_bytes())?;

    let proof_json = generate_proof_base64(&proof, &conf)?;

    if !Path::new("./circom/test/data").is_dir() {
        std::fs::create_dir("./circom/test/data")?;
    }

    let mut proof_file = File::create("./circom/test/data/proof.json")?;
    proof_file.write_all(proof_json.as_bytes())?;

    let mut conf_file = File::create("./circom/test/data/conf.json")?;
    conf_file.write_all(serde_json::to_string(&conf)?.as_ref())?;

    Ok((proof, data.verifier_only, data.common))
}

pub fn main() -> Result<()> {
    const D: usize = 2;
    type C = PoseidonGoldilocksConfig;
    type F = <C as GenericConfig<D>>::F;

    // let conf = generate_verifier_config(&proof)?;
    // let verifier_result = generate_circom_verifier(&conf, common, verifier_only);
    make_proof::<F, C, D>()?;
    //let conf = generate_verifier_config(&proof)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use plonky2_circom_verifier::verifier::generate_circom_verifier;

    use crate::circuits::addition::main;
    #[test]
    fn test_add() {
        main();
    }
}
