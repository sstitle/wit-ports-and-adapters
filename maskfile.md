# Maskfile

This is a [mask](https://github.com/jacobdeichert/mask) task runner file.

## hello

> This is an example command you can run with `mask hello`

```bash
echo "Hello World!"
```

## run

> Build the greeter C bindings via nix (cached)

```bash
nix build .#greeter-c-bindings
echo "C bindings at $(readlink result)/"
ls "$(readlink result)/"
```

## greet-cpp (name)

> Build and run the C++ greeter adapter via nix (cached)

```bash
nix run .#greeter-cpp -- "$name"
```
