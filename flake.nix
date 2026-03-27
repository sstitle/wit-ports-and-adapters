{
  description = "Development environment with nickel and mask";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        # keep-sorted start
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        # keep-sorted end
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          packages = {
            greeter-c-bindings = pkgs.runCommand "greeter-c-bindings" {
              nativeBuildInputs = [ pkgs.wit-bindgen ];
            } ''
              wit-bindgen c ${./wit} --out-dir $out
            '';

            greeter-cpp = pkgs.stdenv.mkDerivation {
              pname = "greeter-cpp";
              version = "0.1.0";
              src = ./src;
              nativeBuildInputs = [ pkgs.gcc ];
              buildPhase = ''
                g++ -I${self'.packages.greeter-c-bindings} -o greeter greeter.cpp
              '';
              installPhase = ''
                mkdir -p $out/bin
                cp greeter $out/bin/greeter-cpp
              '';
            };
          };

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # Core tools
              git
              mask
              # keep-sorted start
              gcc
              wasm-tools
              wit-bindgen
              # keep-sorted end
            ];

            shellHook = ''
              echo "🚀 Development environment loaded!"
              echo "Available tools:"
              echo "  - mask: Task runner"
              echo "  - wit-bindgen: Generate language bindings from WIT files"
              echo "  - wasm-tools: Inspect and manipulate Wasm components"
              echo ""
              echo "Run 'mask --help' to see available tasks."
              echo "Run 'nix fmt' to format all files."
            '';
          };

          # for `nix fmt`
          formatter = treefmtEval.config.build.wrapper;

          # for `nix flake check`
          checks = {
            formatting = treefmtEval.config.build.check self;
          };
        };
    };
}
