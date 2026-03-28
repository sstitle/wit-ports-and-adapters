# Maskfile

This is a [mask](https://github.com/jacobdeichert/mask) task runner file.

## run

> Build Rust component, generate Python bindings, and run the Python host

```bash
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
RUST_DIR="$ROOT/text-analysis/rust-component"
PYTHON_DIR="$ROOT/text-analysis/python-host"
WASM="$RUST_DIR/target/wasm32-unknown-unknown/release/text_analyzer.wasm"

echo "==> [1/3] Building Rust component (wasm32-unknown-unknown)"
cd "$RUST_DIR"
cargo component build --release --target wasm32-unknown-unknown
echo ""

echo "==> [2/3] Generating Python bindings from .wasm"
cd "$PYTHON_DIR"
uv run python3 -m wasmtime.bindgen "$WASM" --out-dir text_analysis
echo ""

echo "==> [3/3] Running Python host"
cd "$PYTHON_DIR"
uv run python host.py
```
