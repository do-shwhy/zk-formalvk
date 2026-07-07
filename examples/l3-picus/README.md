# L3 约束层：Picus 检查 under-constrained circuit

这个例子使用真实 L3 工具 [Picus](https://github.com/Veridise/Picus) 检查一个 Circom circuit 是否 under-constrained。

Picus 是 QED² 的实现，目标是检查 ZK circuit 的 uniqueness / under-constrained 问题。它支持 Circom、R1CS、gnark 等输入。

## 例子

`unsafe_square.circom` 的预期语义是：

```text
b = a * a
```

但它写成了：

```circom
b <-- a * a;
```

`<--` 只影响 witness generation，不会生成 verifier 约束。因此从约束层看，`b` 没有被约束。

## 运行

本示例用 Picus 官方 Docker 构建路径运行，避免在本机安装 Racket、cvc5、Circom 等依赖。

从仓库根目录执行：

```bash
bash examples/l3-picus/run-picus.sh
```

脚本会：

1. 如果本地 Picus 缓存不存在，则克隆 Picus（可用 `PICUS_DIR` 覆盖位置）；
2. 构建 Docker 镜像 `picus:zk-formalvk`；
3. 在容器里运行：

```bash
./run-picus /workspace/examples/l3-picus/unsafe_square.circom
```

## 预期结果

运行脚本后，Picus 会报告 under-constrained counterexample。输出摘要：

```text
The circuit is underconstrained
Counterexample:
  inputs:
    main.a: 0
  first possible outputs:
    main.b: 0
  second possible outputs:
    main.b: 1
Exiting Picus with the code 9
```

Picus 返回 code 9 表示发现 under-constrained counterexample，这是本 demo 的预期结果。
`run-picus.sh` 会把这个预期结果转换成 exit code 0，方便 showcase 直接运行。

## 这个例子说明什么

L2 的 Circomspect 看到的是源码层面的可疑写法：

```text
这里用了 <--，可能没有生成约束。
```

L3 的 Picus 看到的是约束层面的实际后果：

```text
同一个 public/private input main.a = 0 下，
main.b = 0 和 main.b = 1 都能满足约束。
```

也就是：

```text
constraints(a, b0) ∧ constraints(a, b1) ∧ b0 ≠ b1
```

Picus 给出了具体 counterexample，所以这已经不是单纯 lint，而是约束层面的 under-constrained 证据。

## 和 CIVER / halo2-analyzer 的关系

- Picus / QED²：检查 uniqueness / under-constrained，能给 counterexample；
- CIVER：针对 Circom 做 weak-safety、tag、pre/postcondition 的 SMT 验证；
- halo2-analyzer / Korrekt：针对 Halo2 / PLONKish 电路做 unused gate、unconstrained cell、under-constrained 等检查。

本目录选择 Picus，因为它能在这个仓库里通过 Docker 跑通，并且和这个最小 Circom 例子直接匹配。
