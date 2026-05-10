{
  stdenv,
  lib,
  fetchFromGitHub,
  nodejs_22,
  pnpmConfigHook,
  pnpm_9,
  fetchPnpmDeps,
}:

let
  pnpm = pnpm_9;
  nodejs = nodejs_22;

  version = "4.18.1";
  src = fetchFromGitHub {
    owner = "NapNeko";
    repo = "NapCatQQ";
    rev = "v${version}";
    hash = "sha256-KdDxTyiSk7LQjJQmFRN7ydovYFsTcIqwXL3/NwwVCCQ=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "napcat-qq-shell";
  inherit version src;
  # pnpmWorkspaces = [
  #   "napcat-shell"
  #   "napcat-webui-frontend"
  #   "napcat-plugin-builtin"
  # ];

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      # pnpmWorkspaces
      ;
    inherit pnpm;
    fetcherVersion = 3;
    # hash = "sha256-advQVEgSolQFfdwnzfq4V6moHJWE9Ev1MfiSoOEVM6Y=";
    hash = "sha256-d44UNv8rPIXjCteeu2fsZEPumHsuilbe0nKL9ymzfbM=";
  };

  # checkPhase = ''
  #   runHook preCheck
  #
  #   pnpm run typecheck
  #   pnpm test
  #
  #   runHook postCheck
  # '';

  buildPhase = ''
    runHook preBuild

    pnpm --filter napcat-webui-frontend run build
    pnpm run build:shell
    pnpm --filter napcat-plugin-builtin run build

    runHook postBuild
  '';

  # installPhase = ''
  #   runHook preInstall
  #   pnpm --filter napcat-shell deploy --prod --offline --ignore-scripts $out
  #   runHook postInstall
  # '';
  dontCheckForBrokenSymlinks = true;
  installPhase = ''
    runHook preInstall

    rm -r node_modules

    pushd packages/napcat-shell/dist
    CI=true pnpm install --offline --prod --ignore-scripts --filter napcat-shell
    mkdir -p $out
    cp -r . $out/
    popd

    cp -r node_modules $out/

    runHook postInstall
  '';

  meta = {
    description = "现代化的基于 NTQQ 的 Bot 协议端实现";
    homepage = "https://github.com/NapNeko/NapCatQQ";
    license = lib.licenses.mit;
    # FIXME(jinser): no main program actually, or somehow provide a wrapper?
    mainProgram = "napcat.mjs";
    platforms = lib.platforms.all;
  };
})
