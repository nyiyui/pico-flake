{
  description = "Raspberry Pi Pico C SDK project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-for-cmake.url = "github:NixOS/nixpkgs/10b813040df67c4039086db0f6eaf65c536886c6";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-for-cmake,
      flake-utils,
      ...
    }@attrs:
    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (
      system:
      let
        pico-sdk-tinyusb-overlay = final: prev: {
          pico-sdk = prev.pico-sdk.override {
            withSubmodules = true;
          };
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ pico-sdk-tinyusb-overlay ];
        };
        pkgs-for-cmake = import nixpkgs-for-cmake {
          inherit system;
        };
        nativeBuildInputs =
          pkgs: pkgs-for-cmake: with pkgs; [
            pkgs-for-cmake.cmake
            ninja
            gcc-arm-embedded
            picotool
            newlib
          ];
        build =
          pkgs:
          pkgs.stdenv.mkDerivation {
            name = "pico-pio-pwm";
            src = ./.;
            nativeBuildInputs = nativeBuildInputs pkgs pkgs-for-cmake;
            PICO_SDK_PATH = "${pkgs.pico-sdk}/lib/pico-sdk";
            configurePhase = ''
              mkdir build
              cd build
              cmake .. -GNinja
            '';
            buildPhase = ''
              pwd
              ls -al
              ninja
            '';
            installPhase = ''
              mkdir -p $out
              cp *.{elf,uf2} $out
            '';
          };
        build-openocd =
          pkgs:
          pkgs.openocd.overrideAttrs (old: {
            pname = "openocd";
            src = pkgs.fetchFromGitHub {
              owner = "raspberrypi";
              repo = "openocd";
              rev = "8b8c9731a514d3e4dd367d4e77826711201b81b3";
              hash = "sha256-8IsFrr5xYDSGZCT2AuHw5lIa73ZG6NGkFZL1IJrN08U=";
              # The openocd Nix package disables the vendored libraries that use submodules and replaces them with Nix versions.
              # This works out as one of the submodule sources seems to be flakey.
              fetchSubmodules = false;
            };
            nativeBuildInputs = old.nativeBuildInputs ++ [
              pkgs.autoreconfHook
            ];
          });

      in
      {
        devShells.default = pkgs.mkShell {
          packages =
            (with pkgs; [
              pico-sdk
              clang-tools
              gdb
              (build-openocd pkgs)
            ])
            ++ nativeBuildInputs pkgs pkgs-for-cmake;
          shellHook = ''
            export PICO_SDK_PATH=${pkgs.pico-sdk}/lib/pico-sdk
          '';
        };
        packages.default = build pkgs;
      }
    );
}
