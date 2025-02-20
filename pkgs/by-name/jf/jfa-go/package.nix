{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  stdenv,
  darwin,
  libayatana-appindicator,
}:

buildGoModule rec {
  pname = "jfa-go";
  version = "unstable-2024-11-05";

  src = fetchFromGitHub {
    owner = "hrfee";
    repo = "jfa-go";
    rev = "0ccc31483320d79a977a98e374b148f1d0a9398c";
    hash = "sha256-1fiqjty9lHWGIO8CQxFsH1TjbYYU+LR+oqNzYhfqvrQ=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.WebKit
  ] ++ lib.optionals stdenv.isLinux [
    libayatana-appindicator
  ];

  # ldflags = [
  #   "-X=main.version=${envJfaGoVersion}"
  #   "-X=main.commit=${src.rev}"
  #   "-X=main.updater=${envJfaGoUpdater}"
  #   "${envJfaGoStrip}"
  #   "-X=main.cssVersion=${envJfaGoCssVersion}"
  #   "-X=main.buildTimeUnix=${envJfaGoBuildTime}"
  #   "-X=main.builtBy=${envJfaGoBuiltBy}"
  # ];

  meta = {
    description = "A bit-of-everything user managament app for Jellyfin";
    homepage = "https://github.com/hrfee/jfa-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "jfa-go";
  };
}
