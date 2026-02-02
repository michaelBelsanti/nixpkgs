{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "falcond-profiles";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "PikaOS-Linux";
    repo = "falcond-profiles";
    rev = "f52c3445a9b9aa18401b7c8e9bf532c37758e585";
    hash = "sha256-roi1IkN0fyLF3IjIbQ3RF973Z3RawX6ZTzGQ5hK7LTI=";
  };

  buildPhase = ''
    runHook preBuild

    mkdir $out
    cp -r usr/share $out/share

    runHook postBuild
  '';

  meta = {
    description = "Game profiles for falcond";
    homepage = "https://github.com/PikaOS-Linux/falcond-profiles.git";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ michaelBelsanti ];
    mainProgram = "falcond-profiles";
    platforms = lib.platforms.all;
  };
}
