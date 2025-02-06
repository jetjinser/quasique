{
  lib,
  qq,
  napcat-qq,
  writeText,
  libssh2,
  libGL,
  libuuid,
}:

let
  loadNapCat = writeText "loadNapCat" ''
    const fs = require("fs");
    const path = require("path");
    const hasNapcatParam = process.argv.includes("--no-sandbox");
    if (hasNapcatParam) {
        (async () => {
            await import("file://" + "${napcat-qq}/napcat.mjs");
        })();
    } else {
        require("./application/app_launcher/index.js");
        setTimeout(() => {
            global.launcher.installPathPkgJson.main = "./application/app_launcher/index.js";
        }, 0);
    }
  '';
in
qq.overrideAttrs (_prev: {
  name = "quasique-${napcat-qq.version}";

  postInstall = # bash
    ''
      APP="$out/opt/QQ/resources/app"
      cp ${loadNapCat} "$APP/loadNapCat.js"
      sed -i 's|"main": ".*/index.js"|"main": "./loadNapCat.js"|' "$APP/package.json"

      makeShellWrapper $out/opt/QQ/qq $out/bin/quasique \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix LD_PRELOAD : "${lib.makeLibraryPath [ libssh2 ]}/libssh2.so.1" \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            libGL
            libuuid
          ]
        }" \
        --add-flags "--no-sandbox" \
        "''${gappsWrapperArgs[@]}"
    '';
})
