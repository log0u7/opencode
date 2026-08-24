---
name: asm-x86-arm
description: >
  Read and write assembly for x86-64 (Intel and AT&T syntax) and ARM/AArch64:
  instruction selection, calling conventions, stack frames, syscalls,
  disassembly workflows with objdump/gdb. Use when optimizing hot loops,
  reading compiler output, writing inline asm or freestanding routines,
  reverse-engineering, or debugging at assembly level.
---

# Assembly: x86-64 and AArch64

## Before writing any asm

1. Write the C equivalent, compile with `-O2 -S`, read the output. Compiler output is the correctness baseline.
2. Hand-write asm only for the measured hot spot; verify the speedup.

## x86-64 System V ABI (Linux/macOS)

- Integer/pointer args: `rdi, rsi, rdx, rcx, r8, r9`; return in `rax` (+ `rdx`).
- Vector args: `xmm0-xmm7`. Callee-saved: `rbx, rbp, r12-r15`; everything else caller-saved.
- Stack: 16-byte aligned at call sites; red zone 128 bytes below `rsp` (leaf functions only).
- Syscalls: number in `rax`, args in `rdi/rsi/rdx/r10/r8/r9`, `syscall` instruction, `-errno` convention on failure.

## AArch64 (ARM64, AAPCS64)

- Args/return: `x0-x7` (return in `x0`); callee-saved `x19-x28`, `x29` FP, `x30` LR.
- No red zone; stack pointer must stay 16-byte aligned.
- Syscalls: number in `x8`, `svc #0`.
- Conditional execution via `cmp` + conditional branches or `csel`/`csinc`.

## Syntax notes

- Intel: `mov dst, src` (NASM, GAS `.intel_syntax`). AT&T: `movq src, %dst` with `%` registers and `$` immediates, operand order reversed.
- Prefer named labels over magic offsets; use local labels (`.Lx`) for internal jumps.

## Tooling workflow

- Disassemble: `objdump -d --no-show-raw-insn -M intel binary`.
- Step at instruction level: `gdb` (`layout asm`, `si`, `info registers`).
- Check what the compiler already does before hand-tuning; measure with hyperfine/bench harness.

## Anti-patterns

- Self-modifying assumptions about cache/branch behavior without measurement.
- Inline asm without clobbers/constraints exactly right (silent miscompilation risk).
- Hardcoded offsets into structs; generate them from C where possible.
