// This file was generated by verifier.rs

pragma circom 2.1.0;
include "./goldilocks_ext.circom";
include "./utils.circom";
include "./poseidon.circom";

template WiresAlgebraMul(l, r) {
  signal input wires[NUM_OPENINGS_WIRES()][2];
  signal output out[2][2];
  out[0] <== GlExtAdd()(GlExtMul()(wires[l], wires[r]), GlExtMul()(GlExtMul()(GlExt(7, 0)(), wires[l + 1]), wires[r + 1]));
  out[1] <== GlExtAdd()(GlExtMul()(wires[l], wires[r + 1]), GlExtMul()(wires[l + 1], wires[r]));
}

template ConstraintPush() {
  signal input constraint[2];
  signal input filter[2];
  signal input value[2];

  signal output out[2];
  out <== GlExtAdd()(constraint, GlExtMul()(value, filter));
}

template EvalGateConstraints() {
  signal input constants[NUM_OPENINGS_CONSTANTS()][2];
  signal input wires[NUM_OPENINGS_WIRES()][2];
  signal input public_input_hash[4];
  signal input constraints[NUM_GATE_CONSTRAINTS()][2];
  signal output out[NUM_GATE_CONSTRAINTS()][2];

  // ConstantGate { num_consts: 2 }
  component c_Constant2 = Constant2();
  c_Constant2.constants <== constants;
  c_Constant2.wires <== wires;
  c_Constant2.public_input_hash <== public_input_hash;
  c_Constant2.constraints <== constraints;

  // PublicInputGate
  component c_PublicInputGateLib = PublicInputGateLib();
  c_PublicInputGateLib.constants <== constants;
  c_PublicInputGateLib.wires <== wires;
  c_PublicInputGateLib.public_input_hash <== public_input_hash;
  c_PublicInputGateLib.constraints <== c_Constant2.out;
  out <== c_PublicInputGateLib.out;
}
template Constant2() {
  signal input constants[NUM_OPENINGS_CONSTANTS()][2];
  signal input wires[NUM_OPENINGS_WIRES()][2];
  signal input public_input_hash[4];
  signal input constraints[NUM_GATE_CONSTRAINTS()][2];
  signal output out[NUM_GATE_CONSTRAINTS()][2];

  signal filter[2];
  filter <== GlExtMul()(GlExtSub()(GlExt(0, 0)(), constants[0]), GlExtMul()(GlExtSub()(GlExt(2, 0)(), constants[0]), GlExt(1, 0)()));

  for (var i = 0; i < 2; i++) {
    out[i] <== ConstraintPush()(constraints[i], filter, GlExtSub()(constants[1 + i], wires[i]));
  }
  for (var i = 2; i < NUM_GATE_CONSTRAINTS(); i++) {
    out[i] <== constraints[i];
  }
}
template PublicInputGateLib() {
  signal input constants[NUM_OPENINGS_CONSTANTS()][2];
  signal input wires[NUM_OPENINGS_WIRES()][2];
  signal input public_input_hash[4];
  signal input constraints[NUM_GATE_CONSTRAINTS()][2];
  signal output out[NUM_GATE_CONSTRAINTS()][2];

  signal filter[2];
  filter <== GlExtMul()(GlExtSub()(GlExt(0, 0)(), constants[0]), GlExtMul()(GlExtSub()(GlExt(1, 0)(), constants[0]), GlExt(1, 0)()));

  signal hashes[4][2];
  for (var i = 0; i < 4; i++) {
    hashes[i][0] <== public_input_hash[i];
    hashes[i][1] <== 0;
    out[i] <== ConstraintPush()(constraints[i], filter, GlExtSub()(wires[i], hashes[i]));
  }
  for (var i = 4; i < NUM_GATE_CONSTRAINTS(); i++) {
    out[i] <== constraints[i];
  }
}