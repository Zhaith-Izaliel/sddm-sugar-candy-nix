{
  sddm,
  qtgraphicaleffects,
  qtquickcontrols2,
  qtsvg,
  qtbase,
  mkDerivation,
  lib,
  version ? "git",
  themeConf ? "",
}:

mkDerivation rec {
  pname = "sddm-sugar-candy-nix";
  inherit version;

  src = lib.cleanSourceWith {
    filter = name: type: let
      baseName = baseNameOf (toString name);
    in
    ! (
      lib.hasSuffix ".nix" baseName
    );
    src = lib.cleanSource ../.;
  };

  buildInputs = [
    sddm
    qtgraphicaleffects
    qtquickcontrols2
    qtsvg
    qtbase
  ];

  installPhase = ''
    local installDir=$out/share/sddm/themes/${pname}
    mkdir -p $installDir
    cp -aR . $installDir

    # Applying theme
    ${if themeConf != ""
      then "$installDir/theme.conf < ${themeConf}"
      else ""
    }
  '';
}

