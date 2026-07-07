#!/usr/bin/env python3
"""
L6 verifier/实现层最小示例。

这个脚本不是 ZK proof system，实现的是一个简化模型：
proof_blob 代表“底层 proof cryptographically valid”。
我们只展示 verifier 是否把 proof 绑定到正确 statement / verifying key / public input。
"""

from dataclasses import dataclass
from hashlib import sha256


@dataclass(frozen=True)
class Proof:
    proof_blob: str
    vk_id: str
    statement_hash: str


def hash_statement(app_id: str, circuit_id: str, public_input: str) -> str:
    message = f"app={app_id}|circuit={circuit_id}|public_input={public_input}".encode()
    return sha256(message).hexdigest()


def cryptographic_proof_check(proof: Proof, vk_id: str) -> bool:
    # Toy model: assume this checks pairings/FRI/etc. and proof_blob validity.
    # It intentionally only checks vk_id, not statement_hash.
    return proof.proof_blob == "VALID_PROOF" and proof.vk_id == vk_id


def bad_verify(proof: Proof, vk_id: str, app_id: str, circuit_id: str, public_input: str) -> bool:
    _ = (app_id, circuit_id, public_input)
    return cryptographic_proof_check(proof, vk_id)


def good_verify(proof: Proof, vk_id: str, app_id: str, circuit_id: str, public_input: str) -> bool:
    expected_statement_hash = hash_statement(app_id, circuit_id, public_input)
    return (
        cryptographic_proof_check(proof, vk_id)
        and proof.statement_hash == expected_statement_hash
    )


def main() -> None:
    vk_id = "sudoku-vk-v1"
    app_id = "zk-sudoku-showcase"
    circuit_id = "sudoku-circuit-v1"

    original_public_input = "puzzle_hash=PUZZLE_A"
    replayed_public_input = "puzzle_hash=PUZZLE_B"

    proof_for_puzzle_a = Proof(
        proof_blob="VALID_PROOF",
        vk_id=vk_id,
        statement_hash=hash_statement(app_id, circuit_id, original_public_input),
    )

    print("proof was created for:", original_public_input)
    print("attacker replays it for:", replayed_public_input)
    print()

    print("bad verifier accepts replay:", bad_verify(
        proof_for_puzzle_a,
        vk_id,
        app_id,
        circuit_id,
        replayed_public_input,
    ))
    print("good verifier accepts replay:", good_verify(
        proof_for_puzzle_a,
        vk_id,
        app_id,
        circuit_id,
        replayed_public_input,
    ))
    print()

    print("good verifier accepts original:", good_verify(
        proof_for_puzzle_a,
        vk_id,
        app_id,
        circuit_id,
        original_public_input,
    ))


if __name__ == "__main__":
    main()
