{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeDesktopItem,
  copyDesktopItems,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zap";
  version = "2.16.1";
  src = fetchurl {
    url = "https://github.com/zaproxy/zaproxy/releases/download/v${finalAttrs.version}/ZAP_${finalAttrs.version}_Linux.tar.gz";
    hash = "sha256-Wy64MZsIUSGm6K1Q1p1n2++MhnFm9xqTe/yIjSR6KsE=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "zap";
      exec = "zap";
      icon = "zap";
      desktopName = "ZAP";
      categories = [
        "Development"
        "Security"
        "System"
      ];
      keywords = [
        "network"
        "scan"
        "scanner"
        "web"
        "security"
        "zed"
        "attack"
        "proxy"
      ];
    })
  ];

  buildInputs = [ jre ];

  nativeBuildInputs = [ copyDesktopItems ];

  # From https://github.com/zaproxy/zaproxy/blob/master/zap/src/main/java/org/parosproxy/paros/Constant.java
  version_tag = "20012000";

  # Copying config and adding version tag before first use to avoid permission
  # issues if zap tries to copy config on it's own.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}

    cp -pR . "$out/share/zap/"
    install -Dm644 zap.ico "$out/share/icons/hicolor/256x256/apps/zap.ico"

    cat >> "$out/bin/zap" << EOF
    #!${runtimeShell}
    export PATH="${lib.makeBinPath [ jre ]}:\$PATH"
    export JAVA_HOME='${jre}'
    if ! [ -f "\$HOME/.ZAP/config.xml" ];then
      mkdir -p "\$HOME/.ZAP"
      head -n 2 $out/share/zap/xml/config.xml > "\$HOME/.ZAP/config.xml"
      echo "<version>${finalAttrs.version_tag}</version>" >> "\$HOME/.ZAP/config.xml"
      tail -n +3 $out/share/zap/xml/config.xml >> "\$HOME/.ZAP/config.xml"
    fi
    exec "$out/share/zap/zap.sh"  "\$@"
    EOF

    chmod u+x  "$out/bin/zap"

    runHook postInstall
  '';

  meta = {
    homepage = "https://www.zaproxy.org/";
    description = "Java application for web penetration testing";
    maintainers = with lib.maintainers; [
      mog
      rafael
    ];
    platforms = lib.platforms.linux;
    license = lib.licenses.asl20;
    mainProgram = "zap";
  };
})
