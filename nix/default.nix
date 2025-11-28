{
  stdenvNoCC,
  lib,
  pkgs,
  version ? "git",
  themeConf ? ../theme.conf,
}:
stdenvNoCC.mkDerivation rec {
  pname = "sddm-sugar-candy-nix";
  inherit version;

  dontWrapQtApps = true;

  src = lib.cleanSourceWith {
    filter = name: type:
      (builtins.match ".*(nix)" name) == null;
    src = lib.cleanSourceWith {
      filter = name: type: let
        basename = builtins.baseNameOf name;
      in
        (builtins.match "(flake\.lock)|(props\.json)" basename) == null;
      src = lib.cleanSource ../.;
    };
  };

  buildInputs = with pkgs.libsForQt5; [
    qtsvg
    qtbase
    qtquickcontrols2
    qtgraphicaleffects
  ];

  installPhase = ''
    runHook preInstall

    local installDir=$out/share/sddm/themes/${pname}
    mkdir -p $installDir
    cp -aR -t $installDir Main.qml Assets Components metadata.desktop theme.conf Backgrounds

    # Applying theme
    cat "${themeConf}" > "$installDir/theme.conf"

    runHook postInstall
  '';
}
