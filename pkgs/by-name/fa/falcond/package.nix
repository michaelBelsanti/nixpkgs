{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
}:

let
  falcond-profiles-src = fetchFromGitHub {
    owner = "PikaOS-Linux";
    repo = "falcond-profiles";
    rev = "5023a846980685812334586ae265f8f6a1ded38b";
    hash = "sha256-u3yYfRHglQEPpvmICW40TwPIrkL/3NDbm8Mc1O32hmg=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "falcond";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "PikaOS-Linux";
    repo = "falcond";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yBL2ymvxc4G5gMk8aJ8FQao0QbrZEs/3aMPWQcIG9lE=";
    rootDir = "falcond";
  };

  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) src pname version;
    hash = "sha256-liS95CJ9JQ+Eyd4CkqvDhNs4q8AamlX6NewS+IMebQ8=";
  };

  nativeBuildInputs = [ zig ];

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  zigBuildFlags = let
    out = placeholder "out";
  in [
    "-Dprofiles-dir=${out}/share/falcond/profiles"
    "-Duser-profiles-dir=/etc/falcond/profiles/user"
    "-Dsystem-conf-path=${out}/share/falcond/system.conf"
  ];

  postInstall = ''
    cp -r ${falcond-profiles-src}/usr/share $out/share
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "A powerful system daemon designed to automatically optimize your Linux gaming experience";
    longDescription = ''
      falcond is a powerful system daemon designed to automatically optimize your Linux gaming experience. It intelligently manages system resources and performance settings on a per-game basis, eliminating the need to manually configure settings for each game.
    '';
    homepage = "https://github.com/PikaOS-Linux/falcond";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ michaelBelsanti ];
    mainProgram = "falcond";
    platforms = lib.platforms.all;
  };
})
