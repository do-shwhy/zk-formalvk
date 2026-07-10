pragma circom 2.1.6;

template UnsafeDouble() {
    signal input a;
    signal output b;

    b <-- a + a;
}

component main = UnsafeDouble();