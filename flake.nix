{
  description = "A flake to install and configure the SDDM Sugar Candy theme on
  NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib;
    genSystems = lib.genAttrs [
      # Add more systems if they are supported
      "aarch64-linux"
      "x86_64-linux"
    ];

    pkgsFor = genSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.sddm-sugar-candy-nix
        ];
      });
  in
  {
    packages = genSystems (system:
      (self.overlays.default pkgsFor.${system} pkgsFor.${system})
      // {
        default = self.packages.${system}.sddm-sugar-candy-nix;
      }
    );

    overlays = (import ./nix/overlays.nix {}) // {
      default = self.overlays.sddm-sugar-candy-nix;
    };

    nixosModules.default = import ./nix/module.nix inputs;
  };
}

