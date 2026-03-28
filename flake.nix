{
  description = "Cross-language Wasm Component Model demo: Rust guest, Python host, shared WIT";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        # keep-sorted start
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
        # keep-sorted end
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # keep-sorted start
              cargo-component
              git
              mask
              rustup
              uv
              wasm-tools
              wit-bindgen
              # keep-sorted end
            ];

            shellHook = ''
              rustup toolchain install stable --no-self-update 2>/dev/null || true
              rustup target add wasm32-unknown-unknown 2>/dev/null || true
              echo "Development environment ready."
              echo "Run 'mask run' to build the Rust component, generate Python bindings, and run the demo."
              echo "Run 'nix fmt' to format all files."
            '';
          };

          # for `nix fmt`
          formatter = treefmtEval.config.build.wrapper;

          # for `nix flake check`
          checks = { formatting = treefmtEval.config.build.check self; };
        };
    };
}
