{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  olm,
  libayatana-appindicator,
  matrixE2EESupport ? false,
  traySupport ? false,
  nodejs,
  go-swag, esbuild, typescript, stdenv, importNpmLock,
}:
let
  version = "unstable-2024-11-05";
  src = fetchFromGitHub {
    owner = "hrfee";
    repo = "jfa-go";
    rev = "0ccc31483320d79a977a98e374b148f1d0a9398c";
    hash = "sha256-1fiqjty9lHWGIO8CQxFsH1TjbYYU+LR+oqNzYhfqvrQ=";
  };
  scripts = {
    ini = buildGoModule {
      inherit src version;
      pname = "jfa-go-scripts-ini";
      vendorHash = "sha256-Zwn4w4kiKaPEbA3C8CPo6Xwd42CZFTnniqTl2dngJlg=";
      patches = [ ./ini-deps.patch ];
      modRoot = "./scripts/ini";
    };
  };

in
buildGoModule rec {
  pname = "jfa-go";
  inherit src version;

  vendorHash = "";

  npm-deps = stdenv.mkDerivation {
    pname = pname + "-webui";
    inherit version src;

    npmDeps = importNpmLock {
      npmRoot = ./.;
    };

    nativeBuildInputs = [
      nodejs
      importNpmLock.npmConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      # Create data directory
      mkdir -p data/web/js
      mkdir -p data/web/css

      # Generate config-default.ini file
      ${scripts.ini}/bin/ini -in config/config-base.yaml -out data/config-default.ini

      # Generate email HTML files
      npx mjml mail/*.mjml -o data/
      cp mail/*.txt data/

      # Compile TypeScript files
      npx run tsc -noEmit --project ts/tsconfig.json
      rm -rf tempts
      cp -r ts tempts
      scripts/dark-variant.sh tempts
      scripts/dark-variant.sh tempts/modules
      for file in ts/*.ts; do
        esbuild --target=es6 --bundle "$file" --sourcemap --outfile="data/web/js/$(basename "$file" .ts).js" --minify
      done
      rm -r tempts

      # Generate Swagger documentation
      swag init -g main.go

      # Copy HTML files and add dark variants
      cp -r html data/
      node scripts/missing-colors.js html data/html

      # Copy static files
      cp images/banner.svg static/banner.svg
      cp -r static/* data/web/
      cp jfa-go.service data/
      cp -r lang data/
      cp LICENSE data/

      runHook postBuild
    '';
  };

  preBuild = ''
    cp -r ${npm-deps}/data .
    cp -r ${npm-deps}/docs .
    cp -r ${npm-deps}/static .
  '';

  nativeBuildInputs = [
    pkg-config
    go-swag
    typescript
    esbuild
  ];

  buildInputs =
    lib.optionals matrixE2EESupport [ olm ]
    ++ lib.optionals traySupport [ libayatana-appindicator ];

  ldflags = [
    "-X=main.version=${version}"
    "-X=main.commit=${src.rev}"
    "-X=main.updater=off"
  ];

  tags = lib.optional matrixE2EESupport [ "e2ee" ] ++ lib.optional traySupport [ "tray" ];

  meta = {
    description = "A bit-of-everything user managament app for Jellyfin";
    homepage = "https://github.com/hrfee/jfa-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ michaelBelsanti ];
    mainProgram = "jfa-go";
  };
}
