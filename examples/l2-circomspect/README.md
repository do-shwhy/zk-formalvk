# L2 程序/DSL 层：Circom + Circomspect

这个例子展示在还没有检查生成的 R1CS 约束之前，如何先在 Circom DSL 层发现一个问题。

`unsafe_square.circom` 使用 `<--` 给输出赋值：

```circom
b <-- a * a;
```

在 Circom 中，`<--` 只给 witness 赋值，不会生成 verifier 约束。这个例子的预期 relation 是 `b = a * a`，但 DSL 程序没有真正约束它。

## 文件

- `unsafe_square.circom`：最小不安全 Circom 示例。

## 安装

```bash
cargo install circomspect
```

## 运行

在仓库根目录执行：

```bash
circomspect examples/l2-circomspect/unsafe_square.circom
```

预期会发现：

- 使用了 `<--`，而这里更适合用 `<==`；
- `b` 被赋值但从未读取；
- `a` 没有被该 template 约束。

Circomspect 发现 issue 时会返回非 0 exit code。这个 demo 中这是预期结果。

## 为什么这是 L2

这是程序/DSL 层检查。它捕获可疑的源码级模式，但不证明完整 functional correctness，也不能替代 L3 约束/AIR 层验证。
