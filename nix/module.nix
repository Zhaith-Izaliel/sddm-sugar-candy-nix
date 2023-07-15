inputs: { config, lib, pkgs, ... }:

with lib; let
  # Config
  cfg = config.services.xserver.displayManager.sddm.sugarCandy;
  mkTranslationOption = name: example: mkOption {
    default = "";
    inherit example;
    description = "Add a translation for ${name}.";
    type = types.str;
  };

  # Theme configuration generator
  mkThemeConf = settings:
  let
    configStrings = attrsets.mapAttrsToList ( name: value:
    "${name} = \"${if builtins.isString value
      then value
      else toString value
    }\"\n" ) settings;
  in
    strings.concatStrings ( [ "[General]\n\n" ] ++ configStrings );

  # Theme configuration file after generation
  theme-conf-file = pkgs.writeText "sddm-sugar-candy-nix.conf" (mkThemeConf
    cfg.settings);

  # Final Package
  defaultPackage =
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      themeConf = "${theme-conf-file}";
    };
in
{
  options.services.xserver.displayManager.sddm.sugarCandy = {
    enable = mkEnableOption "SDDM Sugar Candy Theme";

    package = mkOption {
      default = defaultPackage;
      defaultText = literalExpression ''

      '';
      example = literalExpression "pkgs.sddm-sugar-candy-nix";
      description = mdDoc ''
        The SDDM Sugar Candy Theme to use.
        Setting this option will make
        {option}`services.xserver.displayManager.sddm.sugarCandy.settings` not
        work.
      '';
      type = types.path;
    };

    settings = {
      Background = mkOption {
        default = ../Backgrounds/Mountain.jpg;
        example = ../Backgrounds/Mountain.jpg;
        description = ''Set the theme background. Must be a path.
        Most standard image file formats are allowed including support for transparency. (e.g. background.jpeg/illustration.GIF/Foto.png/undraw.svgz)"
        '';
        type = types.path;
      };

      DimBackgroundImage = mkOption {
        default = 0.0;
        example = 0.5;
        description = "Float between 0 and 1 used for the alpha channel of a darkening overlay. Use to darken your background image on the fly.";
        type = types.float;
      };

      ScaleImageCropped = mkOption {
        default = true;
        example = false;
        description = ''
        Whether the image should be cropped when scaled proportionally.
        Setting this to false will fit the whole image instead, possibly leaving white space.
        This can be exploited beautifully with illustrations (try it with "undraw.svg" included in the theme).
        '';
        type = types.bool;
      };

      ScreenWidth = mkOption {
        default = 1440;
        example = 1920;
        description = "Adjust to your resolution to help SDDM speed up on calculations.";
        type = types.int;
      };

      ScreenHeight = mkOption {
        default = 900;
        example = 1080;
        description = "Adjust to your resolution to help SDDM speed up on calculations.";
        type = types.int;
      };

      FullBlur = mkEnableOption "full Blur effect";

      PartialBlur = mkOption {
        default = false;
        example = true;
        description = ''
          Wether to enable the partial blur effect.
          If HaveFormBackground is enabled then PartialBlur will trigger the
          BackgroundColor of the form element to be partially transparent and
          blend with the blur.
        '';
        type = types.bool;
      };

      BlurRadius = mkOption {
        default = 100;
        example = 0;
        description = "Set the strength of the blur effect. Anything above 100
        is pretty strong and might slow down the rendering time. 0 is like
        setting false for any blur.";
        type = types.ints.unsigned;
      };

      HaveFormBackground = mkOption {
        default = false;
        example = true;
        description = ''
          Have a full opacity background color behind the form that takes
          slightly more than 1/3 of screen estate.
          If PartialBlur is set to true then HaveFormBackground will trigger
          the BackgroundColor of the form element to be partially transparent
          and blend with the blur.
        '';
        type = types.bool;
      };

      FormPosition = mkOption {
        default = "center";
        example = "left";
        description = "Position of the form which takes roughly 1/3 of screen
        estate. Can be left, center or right.";
        type = types.enum [ "center" "left" "right" ];
      };

      BackgroundImageHAlignment = mkOption {
        default = "center";
        example = "right";
        description = "Horizontal position of the background picture relative to
        its visible area. Applies when ScaleImageCropped is set to false or when
        HaveFormBackground is set to true and FormPosition is either left or
        right. Can be left, center or right; defaults to center if none is
        passed";
        type = types.enum [ "center" "left" "center" ];
      };

      BackgroundImageVAlignment = mkOption {
        default = "center";
        example = "right";
        description = "Vertical position of the background picture relative to
        its visible area. Applies when ScaleImageCropped is set to false or when
        HaveFormBackground is set to true and FormPosition is either left or
        right. Can be left, center or right; defaults to center if none is
        passed";
        type = types.enum [ "center" "left" "right" ];
      };

      MainColor = mkOption {
        default = "white";
        example = "#444";
        description = literalMD ''
          Used for all elements when not focused/hovered etc. Usually the best
          effect is achieved by having this be either white or a very dark grey
          like #444 (not black for smoother antialias). Colors can be HEX or Qt
          names (e.g. red/salmon/blanchedalmond). See
          https://doc.qt.io/qt-5/qml-color.html
        '';
        type = types.nonEmptyStr;
      };

      AccentColor = mkOption {
        default = "#fb884f";
        example = "#38f8dd";
        description = "Used for elements in focus/hover/pressed. Should be
        contrasting to the background and the MainColor to achieve the best
        effect.";
        type = types.nonEmptyStr;
      };

      BackgroundColor = mkOption {
        default = "#444";
        example = "#adfddd";
        description = "Used for the user and session selection background as
        well as for ScreenPadding and FormBackground when either is true. If
        PartialBlur and FormBackground are both enabled this color will blend
        with the blur effect.";
        type = types.nonEmptyStr;
      };

      OverrideLoginButtonTextColor = mkOption {
        default = "";
        example = "#ffffff";
        description = "The text of the login button may become difficult to read
        depending on your color choices. Use this option to set it independently
        for legibility.";
        type = types.str;
      };

      InterfaceShadowSize = mkOption {
        default = 6;
        example = 3;
        description = "Integer used as multiplier. Size of the shadow behind the
        user and session selection background. Decrease or increase if it looks
        bad on your background. Initial render can be slow for values above
        5-7.";
        type = types.ints.unsigned;
      };

      InterfaceShadowOpacity = mkOption {
        default = 0.6;
        example = 0.1;
        description = "Float between 0 and 1. Alpha channel of the shadow
        behind the user and session selection background. Decrease or increase
        if it looks bad on your background.";
        type = types.float;
      };

      RoundCorners = mkOption {
        default = 20;
        example = 10;
        description = "Integer in pixels. Radius of the input fields and the
        login button. Empty for square. Can cause bad antialiasing of the
        fields.";
        type = types.ints.unsigned;
      };

      ScreenPadding = mkOption {
        default = 0;
        example = 10;
        description = "Integer in pixels. Increase or set this to 0 to have a
        padding of color BackgroundColor all around your screen. This makes your
        login greeter appear as if it was a canvas.";
        type = types.ints.unsigned;
      };

      Font = mkOption {
        default = "Noto Sans";
        example = "Fira Code";
        description = "Select a custom font. Must be installed globally in your
        Nix configuration.";
        type = types.nonEmptyStr;
      };

      FontSize = mkOption {
        default = "";
        example = "14";
        description = "Only set a fixed value if fonts are way too small for
        your resolution. Preferrably kept empty.";
        type = types.str;
      };

      ForceRightToLeft = mkOption {
        default = false;
        example = true;
        description = "Revert the layout either because you would like the login
        to be on the right hand side or SDDM won't respect your language locale
        for some reason. This will reverse the current position of FormPosition
        if it is either left or right and in addition position some smaller
        elements on the right hand side of the form itself (also when
        FormPosition is set to center).";
        type = types.bool;
      };

      ForceLastUser = mkOption {
        default = true;
        example = false;
        description = "Have the last successfully logged in user appear
        automatically in the username field.";
        type = types.bool;
      };

      ForcePasswordFocus = mkOption {
        default = true;
        example = false;
        description = "Give automatic focus to the password field. Together with
        forceLastUser this makes for the fastest login experience.";
        type = types.bool;
      };

      ForceHideCompletePassword = mkOption {
        default = false;
        example = true;
        description = "If you don't like to see any character at all not even
        while being entered set this to true.";
        type = types.bool;
      };

      ForceHideVirtualKeyboardButton = mkOption {
        default = false;
        example = true;
        description = "Do not show the button for the virtual keyboard at all.
        This will completely disable functionality for the virtual keyboard even
        if it is installed and activated in sddm.conf";
        type = types.bool;
      };

      ForceHideSystemButtons = mkOption {
        default = false;
        example = true;
        description = "Completely disable and hide any power buttons on the
        greeter.";
        type = types.bool;
      };

      Locale = mkOption {
        default = "";
        example = "fr";
        description = "The time and date locale should usually be set in your
        system settings. Only hard set this if something is not working by
        default or you want a seperate locale setting in your login screen.";
        type = types.str;
      };

      HourFormat = mkOption {
        default = "HH:mm";
        example = "HH:mm:ss";
        description = literalMD ''
          Defaults to Locale.ShortFormat - Accepts "long"
          or a custom string like "hh:mm A". See
          http://doc.qt.io/qt-5/qml-qtqml-date.html
        '';
        type = types.str;
      };

      DateFormat = mkOption {
        default = "dddd, d of MMMM";
        example = "dddd";
        description = literalMD ''
          Defaults to Locale.LongFormat - Accepts "short" or a custom string
          like "dddd, d 'of' MMMM". See
          http://doc.qt.io/qt-5/qml-qtqml-date.html
        '';
        type = types.str;
      };

      HeaderText = mkOption {
        default = "Welcome!";
        example = "Bienvenue!";
        description = "Header can be empty to not display any greeting at all.
        Keep it short.";
        type = types.str;
      };

      TranslatePlaceholderUsername = mkTranslationOption "the username
      placeholder" "Nom d'utilisateur";

      TranslatePlaceholderPassword = mkTranslationOption " the password
      placeholder" "Mot de passe";

      TranslateShowPassword = mkTranslationOption "show password" "Afficher le
      mot de passe";

      TranslateLogin = mkTranslationOption "login" "Connexion";

      TranslateLoginFailedWarning = mkTranslationOption "the login failed warning"
      "Echec de l'authentification";

      TranslateCapslockWarning = mkTranslationOption "the caps lock warning"
      "Verr. Maj. actif";

      TranslateSession = mkTranslationOption "the session button" "Session";

      TranslateSuspend = mkTranslationOption "the suspend button" "Suspendre";

      TranslateHibernate = mkTranslationOption "the hibernate button"
      "Hibernation";

      TranslateReboot = mkTranslationOption "the reboot button" "Redémarrer";

      TranslateShutdown = mkTranslationOption "the shutdown button" "Arrêt";

      TranslateVirtualKeyboardButton = mkTranslationOption "the virtual
      keyboard button" "Clavier virtuel";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.displayManager.sddm = {
      enable = true;
      theme = "sddm-sugar-candy-nix";
    };

    environment.systemPackages = with pkgs.libsForQt5; [
      cfg.package
      sddm
      qtgraphicaleffects
      qtquickcontrols2
      qtsvg
      qtbase
    ];
  };
}

