{
  description =
    "Raspberry Pi Pico template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@attrs:
    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (system:
      let
        pico-sdk-tinyusb-overlay = final: prev: {
          pico-sdk = prev.pico-sdk.override {
            withSubmodules = true;
          };
        };
        pkgs = import nixpkgs { inherit system; overlays = [ pico-sdk-tinyusb-overlay ]; };
        build = pkgs: let
          cc = pkgs.gcc-arm-embedded;
        in pkgs.stdenv.mkDerivation {
          name = "pico-pio-pwm";
          src = ./.;
          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            cc
            picotool
            python3
            newlib
          ];
          PICO_SDK_PATH = "${pkgs.pico-sdk}/lib/pico-sdk";
          configurePhase = ''
            mkdir build
            cd build
            cmake .. -GNinja
          '';
          buildPhase = ''
            ninja
          '';
          installPhase = ''
            mkdir -p $out
            cp *.uf2 $out
          '';
        };
      in rec {
        devShells.default = pkgs.mkShell { buildInputs = with pkgs; [
          pico-sdk
          cmake
          gcc-arm-embedded # NOTE normal GCC does not work for some reason
          picotool
          python3
          newlib
          ninja
          clang-tools
        ];
        shellHook = ''
          export PICO_SDK_PATH=${pkgs.pico-sdk}/lib/pico-sdk
        '';
      };
      packages.default = build pkgs;
      });
}

