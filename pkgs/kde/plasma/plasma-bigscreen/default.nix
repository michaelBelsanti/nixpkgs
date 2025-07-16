{
  mkKdeDerivation,
  kdbusaddons,
  kdeconnect-kde,
  kglobalacceld,
  kirigami,
  kscreen,
  milou,
  plasma-nano,
  qtdeclarative,
  qtmultimedia,
  qtquick3d,
  qtsvg,
  qtwayland,
  plasma-workspace,
  fetchFromGitLab,
  lib,
}:
mkKdeDerivation {
  pname = "plasma-bigscreen";

  extraBuildInputs = [
    kdbusaddons
    kdeconnect-kde
    kglobalacceld
    kirigami
    kscreen
    milou
    plasma-nano
    qtdeclarative
    qtmultimedia
    qtquick3d
    qtsvg
    qtwayland
  ];

  passthru.providedSessions = [
    "plasma-bigscreen-wayland"
    "plasma-bigscreen-x11"
  ];

  # temporary
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'set(PROJECT_VERSION "6.4.80")' 'set(PROJECT_VERSION "6.4.3")'
          substituteInPlace bin/plasma-bigscreen-wayland.in \
      --replace-fail @KDE_INSTALL_FULL_LIBEXECDIR@ "${plasma-workspace}/libexec"
  '';

  version = "unstable-2025-06-15";
  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "plasma-bigscreen";
    rev = "58e8e784467958ca2734ddd6f425dfb44ebd1055";
    hash = "sha256-LBx/tTWJMEgcwFYUVIRIwULACoFKoc2qgD9fjSJZcOg=";
  };

  meta = {
    homepage = null;
    license = lib.licenses.gpl3Plus;
  };
}
