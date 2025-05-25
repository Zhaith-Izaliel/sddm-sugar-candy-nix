{}: let
  props = builtins.fromJSON (builtins.readFile ../props.json);
in {
  sddm-sugar-candy-nix = final: prev: {
    sddm-sugar-candy-nix = final.libsForQt5.callPackage ./default.nix {
      version = props.version;
    };
  };
}
