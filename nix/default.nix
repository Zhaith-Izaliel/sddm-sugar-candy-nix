{
  libsForQt5,
  stdenv,
  lib,
  coreutils,
  version ? "git",
  themeConf ? ../theme.conf,
}:

stdenv.mkDerivation rec {
  pname = "sddm-sugar-candy-nix";
  inherit version;

  dontWrapQtApps = true;

  src = lib.cleanSourceWith {
    filter = name: type: let
      baseName = baseNameOf (toString name);
    in
    ! (
      lib.hasSuffix ".nix" baseName
    );
    src = lib.cleanSource ../.;
  };

  propagatedBuildInputs = with libsForQt5.qt5; [
    libsForQt5.sddm
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
    cp -aR . $installDir

    # Applying theme
    cat "${themeConf}" > "$installDir/theme.conf"
  '';
}

