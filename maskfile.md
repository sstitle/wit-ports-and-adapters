# Maskfile

This is a [mask](https://github.com/jacobdeichert/mask) task runner file.

## hello

> This is an example command you can run with `mask hello`

```bash
echo "Hello World!"
```

## run

> Generate C bindings from the greeter WIT interface into generated/c/

```bash
mkdir -p generated/c
wit-bindgen c wit/ --out-dir generated/c
echo "Generated C bindings in generated/c/"
ls generated/c/
```

## greet-cpp (name)

> Compile and run the C++ greeter adapter

```bash
g++ -I. -o /tmp/greeter-cpp src/greeter.cpp
/tmp/greeter-cpp "$name"
```
