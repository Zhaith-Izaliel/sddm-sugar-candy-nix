{
  description = "A flake to install and configure the SDDM Sugar Candy theme on
  NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: with inputs;
  let
    pkgs = nixpkgs.legacyPackages."${system}";
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

    nixosModules.default = import ./nix/module.nix {inherit inputs system; };
  };
}

