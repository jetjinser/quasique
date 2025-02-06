{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_22,
}:

let
  inherit (stdenv.hostPlatform.uname) system;
  target_platform = lib.toLower system;

  nodejs = nodejs_22;

  version = "4.5.14";
  src = fetchFromGitHub {
    owner = "NapNeko";
    repo = "NapCatQQ";
    rev = "v${version}";
    hash = "sha256-h1WbW8Rv/UOl/y4htrI54RWNOn/Zyvdw/113DSq+n5s=";
  };

  webui = buildNpmPackage {
    inherit version nodejs;
    src = "${src}/napcat.webui";
    pname = "nap-cat-qq-webui";

    npmDepsHash = "sha256-tk23rJtFmLZ+ag5ZMlWFx/tXxoTiM4LGSTEv5MUxeTs=";

    postPatch = ''
      cp ${./package-lock.webui.json} ./package-lock.json
    '';

    installPhase = ''
      runHook preInstall
      mkdir $out
      cp -r dist/* $out
      runHook postInstall
    '';
  };
in
buildNpmPackage {
  inherit version src nodejs;
  pname = "nap-cat-qq";

  npmDepsHash = "sha256-wkFt3WjBeaoPS7K+J4YluTiR/FEx5HejIJKTjyNSx3s=";

  patches = [ ./configBase.patch ];

  postPatch = ''
    cp ${./package-lock.shell.json} ./package-lock.json

    sed -i 's/npm run build:webui && //g'  package.json

    mkdir napcat.webui/dist
    cp -r ${webui}/* napcat.webui/dist
  '';

  npmBuildScript = "build:shell";
  buildInputs = [ ];

  preInstall = ''
    cd dist
    cp ../package-lock.json .
    npm ci --omit=dev
    cd ..
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r dist/* $out
    runHook postInstall
  '';

  env.NAPCAT_BUILDSYS = target_platform;

  meta = with lib; {
    description = "现代化的基于 NTQQ 的 Bot 协议端实现 ";
    homepage = "https://github.com/NapNeko/NapCatQQ";
    license = licenses.mit;
    mainProgram = "nap-cat-qq";
    platforms = platforms.all;
  };
}
