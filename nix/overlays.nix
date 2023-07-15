{}:
let
  props = builtins.fromJSON (builtins.readFile ../props.json);
in
{
  # DEBUG: remove themeConf when finished
  sddm-sugar-candy-nix = final: prev: {
    sddm-sugar-candy-nix = final.callPackage ./default.nix {
      version = props.version;
      themeConf = ../theme.conf;
    };
  };
}

