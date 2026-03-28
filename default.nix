{ pkgs, greeter-c-bindings }:

pkgs.clangStdenv.mkDerivation {
  pname = "greeter-cpp";
  version = "0.1.0";
  src = ./src;

  nativeBuildInputs = [ pkgs.cmake pkgs.ninja ];

  cmakeFlags = [ "-DGREETER_BINDINGS_DIR=${greeter-c-bindings}" ];

  installPhase = ''
    mkdir -p $out/bin
    cp greeter $out/bin/greeter-cpp
  '';
}
