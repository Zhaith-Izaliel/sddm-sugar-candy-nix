{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: with inputs;
  let
    pkgs = import nixpkgs { inherit system; };
    props = builtins.fromJSON (builtins.readFile ./props.json);
    system = "x86_64-linux";
  in
  rec {
    packages."${system}".default = pkgs.callPackage ./nix {
      version = props.version;
    };

    overlays.default = final: prev: {
      sddm-sugar-candy-nix = packages."${system}".default;
    };

    nixosModules.default = import ./nix/module.nix inputs;
  };
}

