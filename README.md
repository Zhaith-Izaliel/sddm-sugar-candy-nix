
![Screenshot of the interface of the Sugar Candy theme for SDDM](Previews/PartialBlur.png "The default interface of the Sugar Candy theme for SDDM")

# Sugar Candy login theme for SDDM on NixOS

This is a fork of the Sugar Candy login theme for SDDM made by Marian Arlt
available
[here](https://framagit.org/MarianArlt/sddm-sugar-candy/-/tree/master).

This fork aims to provide a NixOS module to customize the theme using its
impressive number of variables as well as a package to install it at your
convenience.

As of today, the package **does not work properly** due to some dependencies not
being available to SDDM when loading the theme.

If you know how to fix this, feel free to make a pull request following the
contribution guidelines.

## Table of content

<!-- vim-markdown-toc GitLab -->

* [Installation](#installation)
* [Caveats](#caveats)
* [Configuration](#configuration)
* [Examples](#examples)
* [Legal Notice](#legal-notice)

<!-- vim-markdown-toc -->

## Installation

To install it you **must have flake enabled** and your NixOS configuration
**must be managed with flakes.** See [https://nixos.wiki/wiki/Flakes] for
instructions on how to install and enable them on NixOS.

Next, you can add this flake as inputs in `flake.nix` in the repository
containing your NixOS configuration:

```nix
inputs = {
  # ---Snip---
  sddm-sugar-candy-nix = {
    url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
    # Optional, by default this flake follows nixpkgs-unstable.
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # ---Snip---
}
```

This flake provides an overlay for nixpkgs, a package and a NixOS module. They
are respectively found in the flake as
`inputs.sddm-sugar-candy-nix.overlays.default`,
`inputs.sddm-sugar-candy-nix.packages.${system}.default` (Where `${system}` is either
`x86_64-linux` or `aarch64-linux`) and
`inputs.sddm-sugar-candy-nix.nixosModules.default`.

Here is a simple example on how to install both the overlay and the module in
your NixOS configuration:

```nix
outputs = { self, nixpkgs, sddm-sugar-candy-nix }: {
  # replace 'joes-desktop' with your hostname here.
  nixosConfigurations.joes-desktop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      sddm-sugar-candy-nix.nixosModules.default
      # ---Snip---
      # Add your own modules here
      # ---Snip---

      # Example to add the overlay to Nixpkgs:
      {
        nixpkgs = {
          overlays = [
            sddm-sugar-candy-nix.overlays.default
          ];
        };
      }
    ];
  };
};
```

## Caveats

My knowledge with Nix and NixOS is limited and as such the module and package
are imperfect. Hence, there are some caveats to take into considerations:

1. Due to the nature of the theme, its configuration lives in `theme.conf`. As
   such the module will override the derivation to create a new `theme.conf`
   containing your configuration leading to **a complete rebuild and download of
   the theme**. I advise you to run `nix-collect-garbage` when testing some
   configurations of the theme as it will steadily fill up your Nix store.

2. SDDM complains about not having certain dependencies available when using the
   theme. To fix that, I had to make the module install them globally in
   `environment.systemPackages`. Here is the list of dependencies installed
   globally to make the theme work:
   * `sddm`
   * `qtgraphicaleffects`
   * `qtquickcontrols2`
   * `qtsvg`
   * `qtbase`

   This means you will have to install them yourself if you want to only use the
   package as is.

If you have any idea on how to fix these issues, please, feel free to make a
Pull Request following the contribution guidelines. Thank you.

## Configuration

The sugar series is **extremely customizable** by setting the options in the
module. You can change the colors and images used, the time and date formats,
the appearance of the whole interface and even how it works.
And as if that wouldn't still be enough you can translate every single button
and label because SDDM is still lacking behind with localization and clearly
[needs your help](https://github.com/sddm/sddm/wiki/Localization)!

After installing the module, Sugar Candy can be configured by setting its
configuration options in the given module:

```nix
{ ... }:

{
  services.xserver = {
    enable = true;

    displayManager.sddm.sugarCandy = {
      enable = true; # This enables SDDM automatically and set its theme to
                     # "sddm-sugar-candy-nix"
      settings = {
        # Set your configuration options here.
      };
    };
  };
}
```

Below are the configuration options, with their default values, available in
the module. They cover **every single option** the theme provides by default.

`Background = ./Backgrounds/Mountain.jpg;`
*Path to the image. In flake evaluation, must be used with `lib.cleanSource` to
set it as store path to keep purity. Most standard image file formats are
allowed including support for transparency. (e.g.
background.jpeg/illustration.GIF/Foto.png/undraw.svgz)*

`DimBackgroundImage = 0.0;`
*Double between 0 and 1 used for the alpha channel of a darkening overlay. Use
to darken your background image on the fly.*

`ScaleImageCropped = true;`
*Whether the image should be cropped when scaled proportionally. Setting this
to false will fit the whole image instead, possibly leaving white space. This
can be exploited beautifully with illustrations (try it with "undraw.svg"
included in the theme).*

`ScreenWidth = 1440;`
`ScreenHeight = 900;`
*Adjust to your resolution to help SDDM speed up on calculations.*

`FullBlur = false;`
`PartialBlur = false;`
*Enable or disable the blur effect; if HaveFormBackground is set to true then
PartialBlur will trigger the BackgroundColor of the form element to be partially
transparent and blend with the blur.*

`BlurRadius  =  100;`
*Set the strength of the blur effect. Anything above 100 is pretty strong and
might slow down the rendering time. 0 is like setting false for any blur.*

`HaveFormBackground  =  false;`
*Have a full opacity background color behind the form that takes slightly more
than 1/3 of screen estate; if PartialBlur is set to true then HaveFormBackground
will trigger the BackgroundColor of the form element to be partially transparent
and blend with the blur.*

`FormPosition  =  "center";`
*Position of the form which takes roughly 1/3 of screen estate. Can be left,
center or right.*

`BackgroundImageHAlignment = "center";`
*Horizontal position of the background picture relative to its visible area.
Applies when ScaleImageCropped is set to false or when HaveFormBackground is
set to true and FormPosition is either left or right. Can be left, center or
right; defaults to center if none is passed.*

`BackgroundImageVAlignment = "center";`
*As before but for the vertical position of the background picture relative to
its visible area.*

`MainColor = "white";`
*Used for all elements when not focused/hovered etc. Usually the best effect is
achieved by having this be either white or a very dark grey like #444 (not black
for smoother antialias). Colors can be HEX or Qt names (e.g.
red/salmon/blanchedalmond). See
[https://doc.qt.io/qt-5/qml-color.html](https://doc.qt.io/qt-5/qml-color.html)*

`AccentColor = "#fb884f";`
*Used for elements in focus/hover/pressed. Should be contrasting to the
background and the MainColor to achieve the best effect.*

`BackgroundColor = "#444";`
*Used for the user and session selection background as well as for ScreenPadding
and FormBackground when either is true. If PartialBlur and FormBackground are
both enabled this color will blend with the blur effect.*

`OverrideLoginButtonTextColor = "";`
*The text of the login button may become difficult to read depending on your
color choices. Use this option to set it independently for legibility.*

`InterfaceShadowSize = 6;`
*Integer used as multiplier. Size of the shadow behind the user and session
selection background. Decrease or increase if it looks bad on your background.
Initial render can be slow for values above 5-7.*

`InterfaceShadowOpacity = 0.6;`
*Double between 0 and 1. Alpha channel of the shadow behind the user and session
selection background. Decrease or increase if it looks bad on your background.*

`RoundCorners = 20;`
*Integer in pixels. Radius of the input fields and the login button. Empty for
square. Can cause bad antialiasing of the fields.*

`ScreenPadding = 0;`
*Integer in pixels. Increase or delete this to have a padding of color
BackgroundColor all around your screen. This makes your login greeter appear as
if it was a canvas.*

`Font = "Noto Sans";`
*If you want to choose a custom font it will have to be installed globally in
your Nixos configuration.*

`FontSize = "";`
*Only set a fixed value if fonts are way too small for your resolution.
Preferably kept empty. Beware, the font size in string, not an integer.*

`ForceRightToLeft = false;`
*Revert the layout either because you would like the login to be on the right
hand side or SDDM won't respect your language locale for some reason. This will
reverse the current position of FormPosition if it is either left or right and
in addition position some smaller elements on the right hand side of the form
itself (also when FormPosition is set to center).*

`ForceLastUser = true;`
*Have the last successfully logged in user appear automatically in the username
field.*

`ForcePasswordFocus = true;`
*Give automatic focus to the password field. Together with ForceLastUser this
makes for the fastest login experience.*

`ForceHideCompletePassword = false;`
*If you don't like to see any character at all not even while being entered set
this to true.*

`ForceHideVirtualKeyboardButton = false;`
*Do not show the button for the virtual keyboard at all. This will completely
disable functionality for the virtual keyboard even if it is installed and
activated in sddm.conf*

`ForceHideSystemButtons = false;`
*Completely disable and hide any power buttons on the greeter.*

`Locale = "";`
*The time and date locale should usually be set in your system settings. Only
hard set this if something is not working by default or you want a separate
locale setting in your login screen.*

`HourFormat = "HH:mm";`
*Defaults to Locale.ShortFormat - Accepts "long" or a custom string like
"hh:mm A". See [http://doc.qt.io/qt-5/qml-qtqml-date.html]*

`DateFormat = "dddd, d of MMMM";`
*Defaults to Locale.LongFormat - Accepts "short" or a custom string like
"dddd, d 'of' MMMM". See [http://doc.qt.io/qt-5/qml-qtqml-date.html]*

`HeaderText = "Welcome!";`
*Header can be empty to not display any greeting at all. Keep it short.*

*SDDM may lack proper translation for every element. Sugar defaults to SDDM
translations. Please help translate SDDM as much as possible for your language:
[https://github.com/sddm/sddm/wiki/Localization]. These are in order as they
appear on screen.*

`TranslatePlaceholderUsername = "";`
`TranslatePlaceholderPassword = "";`
`TranslateShowPassword = "";`
`TranslateLogin = "";`
`TranslateLoginFailedWarning = "";`
`TranslateCapslockWarning = "";`
`TranslateSession = "";`
`TranslateSuspend = "";`
`TranslateHibernate = "";`
`TranslateReboot = "";`
`TranslateShutdown = "";`
`TranslateVirtualKeyboardButton = "";`

*These don't necessarily need to translate anything. You can enter whatever you
want here.*

## Examples

These are some previews of configurations possible with Sugar Candy.
![Screenshot of Sugar Candy using an illustration as
background.](Previews/ScaleImageCropped.png "An SVG illustration used as background")
![Screenshot of Sugar Candy having a padding around the whole
screen.](Previews/ScreenPadding.png "Using padding for the whole screen")
![Screenshot of Sugar Candy with a right to left
layout.](Previews/ForceRightToLeft.png "Right to left layout")
![Screenshot of Sugar Candy with fully blurred
background.](Previews/FullBlur.png "With fully blurred background")
![Screenshot of Sugar Candy selection
popup.](Previews/InterfacePopup.png "Interface popup")

## Legal Notice

Copyright (C) 2018 Marian Arlt.

Sugar Candy is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Sugar Candy is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
Sugar Candy. If not, see [https://www.gnu.org/licenses/].

*Redistributed by Virgil Ribeyre, under the same license. 2023.*

