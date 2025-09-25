{}: let
  props = builtins.fromJSON (builtins.readFile ../props.json);
in {
  sddm-sugar-candy-nix = final: prev: {
    sddm-sugar-candy-nix = prev.libsForQt5.callPackage ./default.nix {
      sddm = prev.kdePackages.sddm;
      version = props.version;
    };
  };
}
