pragma circom 2.1.6;

template WrongDouble() {
    signal input a;
    signal output b;

    spec_precondition a <= 100;

    b <== a + a + 1;

    spec_postcondition b == a + a;
}

component main = WrongDouble();