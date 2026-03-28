# text-analysis — Wasm Component Model example

A text analysis library implemented in **Rust** as a Wasm component, consumed by a
**Python** host via typed bindings. Both sides share a single WIT interface definition.

The Rust component uses `#![no_std]` + `wee_alloc` so it compiles to
`wasm32-unknown-unknown` with no WASI imports — a pure component with only the
`example:text-analysis/analyzer` export. This is required for compatibility with
`wasmtime.bindgen` 38.x, which does not support WASI resource types.

```
wit/text-analysis.wit          ← shared interface
rust-component/                ← Rust guest (cdylib → .wasm, no_std)
python-host/                   ← Python consumer (wasmtime 38.0.0)
```

The easiest way to run the full demo is:

```sh
mask run
```

---

## Prerequisites

All tools are provided by the Nix devShell (`nix develop` or direnv). Manually:

| Tool | Install |
|------|---------|
| Rust stable + `wasm32-unknown-unknown` target | `rustup target add wasm32-unknown-unknown` |
| `cargo-component` | `cargo install cargo-component` |
| `uv` | https://docs.astral.sh/uv/getting-started/installation/ |

---

## 1 — Build the Rust component

```sh
cd rust-component
cargo component build --release --target wasm32-unknown-unknown
```

The compiled component is written to:

```
rust-component/target/wasm32-unknown-unknown/release/text_analyzer.wasm
```

---

## 2 — Generate Python bindings

Run from inside `python-host/`:

```sh
cd python-host
uv run python3 -m wasmtime.bindgen \
    ../rust-component/target/wasm32-unknown-unknown/release/text_analyzer.wasm \
    --out-dir text_analysis
```

This introspects the WIT metadata embedded in the `.wasm` and writes a typed
Python package to `python-host/text_analysis/`. The directory is git-ignored
and must be regenerated whenever the component is rebuilt.

---

## 3 — Run the host

```sh
cd python-host
uv run python host.py
```

---

## Expected output

```
==> [1/3] Building Rust component (wasm32-unknown-unknown)
...
    Creating component target/wasm32-unknown-unknown/release/text_analyzer.wasm

==> [2/3] Generating Python bindings from .wasm
Generating text_analysis/__init__.py
...

==> [3/3] Running Python host
Raw return type: <class 'text_analysis.types.Ok'>
Raw return value: Ok(value=AnalysisResult(total_words=118, unique_words=73, top_words=[...]))

Total words:  118
Unique words: 73
Top words:
  'to': 13
  'the': 7
  'sleep': 5
  'and': 4
  'of': 4
```
