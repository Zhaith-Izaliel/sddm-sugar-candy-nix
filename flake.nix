{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs;
  flake-utils.lib.eachDefaultSystem (system:
  with import nixpkgs { inherit system; };
  let
    props = builtins.fromJSON (builtins.readFile ./props.json);
  in
    rec {
      packages.default = callPackage ./nix {
          inherit (props) version;
      };

      overlays.default = final: prev: {
        sddm-sugar-candy-nix = packages."${system}".default;
      };
    }
  ) // {
    nixosModules.default = import ./nix/module.nix inputs;
  };
}

