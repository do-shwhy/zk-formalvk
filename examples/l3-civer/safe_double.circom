pragma circom 2.1.6;

template Double() {
    signal input a;
    signal output b;

    spec_precondition a <= 100;

    b <== a + a;

    spec_postcondition b == a + a;
}

component main = Double();