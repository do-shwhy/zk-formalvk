pragma circom 2.0.0;

template UnsafeSquare() {
    signal input a;
    signal output b;

    b <-- a * a;
}

component main = UnsafeSquare();
