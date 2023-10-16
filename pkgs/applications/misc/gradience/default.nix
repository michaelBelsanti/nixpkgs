{ stdenv
, lib
, fetchFromGitHub
, wrapGAppsHook4
, meson
, ninja
, pkg-config
, glib
, glib-networking
, desktop-file-utils
, gettext
, librsvg
, blueprint-compiler
, python3Packages
, sassc
, appstream-glib
, libadwaita
, libportal
, libportal-gtk4
, libsoup_3
, gobject-introspection
}:

python3Packages.buildPythonApplication rec {
  pname = "gradience";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "michaelBelsanti";
    repo = "Gradience";
    rev = "31b8bd7f758060d17f6810340793378638552252";
    hash = "sha256-z4S6QF8WGZPSsuYCEZ9TbfkaPaHSJo29K0t9MinsgWI=";
    fetchSubmodules = true;
  };

  format = "other";
  dontWrapGApps = true;

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    gettext
    glib
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    sassc
  ];

  buildInputs = [
    glib-networking
    libadwaita
    libportal
    libportal-gtk4
    librsvg
    libsoup_3
  ];

  propagatedBuildInputs = with python3Packages; [
    anyascii
    jinja2
    lxml
    material-color-utilities
    pygobject3
    svglib
    yapsy
    libsass
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib; {
    homepage = "https://github.com/GradienceTeam/Gradience";
    description = "Customize libadwaita and GTK3 apps (with adw-gtk3)";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
