{
  description = "A flake to install and configure the SDDM Sugar Candy theme on
  NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: let
      version = "2.11.0";
    in {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {pkgs, ...}: {
        devShells = {
          # nix develop
          default = let
            qtEnv = with pkgs.qt6;
              env "qt-custom-${qtbase.version}" [
                qtdeclarative
                qtsvg
                qt5compat
              ];
          in
            pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                kdePackages.sddm
                qtEnv
              ];
            };
        };

        packages = {
          default = pkgs.callPackage ./nix {inherit version;};
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
