{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs;
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
    props = builtins.fromJSON (builtins.readFile ./props.json);
  in
    rec {
      packages.default = pkgs.callPackage ./nix {
        version = props.version;
      };

      overlays.default = final: prev: {
        sddm-sugar-candy-nix = packages."${system}".default;
      };
    }
  ) // {
    nixosModules.default = import ./nix/module.nix inputs;
  };
}

