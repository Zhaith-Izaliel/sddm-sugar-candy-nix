{
  stdenvNoCC,
  lib,
  coreutils,
  sddm,
  qtbase,
  qtsvg,
  qtquickcontrols2,
  qtgraphicaleffects,
  version ? "git",
  themeConf ? ../theme.conf,
}:
stdenvNoCC.mkDerivation rec {
  pname = "sddm-sugar-candy-nix";
  inherit version;

  dontWrapQtApps = false;

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

  propagatedUserEnvPkgs = [
    sddm
    qtbase
    qtsvg
    qtgraphicaleffects
    qtquickcontrols2
  ];

  nativeBuildInputs = [
    coreutils
  ];

  installPhase = ''
    local installDir=$out/share/sddm/themes/${pname}
    mkdir -p $installDir
    cp -aR -t $installDir Main.qml Assets Components metadata.desktop theme.conf Backgrounds

    # Applying theme
    cat "${themeConf}" > "$installDir/theme.conf"
  '';

  QT_PLUGIN_PATH = lib.makeLibraryPath [
    qtbase
    qtsvg
    qtquickcontrols2
    qtgraphicaleffects
  ];

  QML2_IMPORT_PATH = lib.makeLibraryPath [
    qtbase
    qtquickcontrols2
    qtgraphicaleffects
  ];

  wrapperArgs = [
    "--prefix"
    "QT_PLUGIN_PATH"
    ":"
    "${QT_PLUGIN_PATH}"
    "--prefix"
    "QML2_IMPORT_PATH"
    ":"
    "${QML2_IMPORT_PATH}"
  ];

  passthru = {
    inherit QT_PLUGIN_PATH QML2_IMPORT_PATH;
  };
}
