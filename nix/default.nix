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

  buildInputs = with libsForQt5; [
    coreutils
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
    cat "${builtins.trace "path: ${themeConf}" themeConf}" > "$installDir/theme.conf"
  '';
}

