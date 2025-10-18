{
  description = "A flake to install and configure the SDDM Sugar Candy theme on
  NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: let
      version = "2.10.2";
    in {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {pkgs, ...}: {
        devShells = {
          # nix develop
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              kdePackages.sddm
              # kdePackages.qtbase
              # kdePackages.qt5compat
              qt6.full
              qt6.qtbase
              qt6.qtsvg
              # kdePackages.qtsvg
            ];
          };
        };

        packages = {
          default = pkgs.kdePackages.callPackage ./nix {inherit version;};
        };
      };

      flake = {
        overlays.default = final: prev: let
          packages = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
        in {sddm-sugar-candy-nix = packages.default;};

        nixosModules.default = {pkgs, ...}: let
          module = import ./nix/module.nix {sddm-sugar-candy-nix = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.default);};
        in {
          imports = [module];
        };
      };
    });
}
