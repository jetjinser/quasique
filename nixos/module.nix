{
  lib,
  pkgs,
  config,
  ...
}:

let
  defaultUser = "quasique";
  cfg = config.services.quasique;

  inherit (lib) types;
in
{
  options.services.quasique = {
    enable = lib.mkEnableOption "Whether to enable quasique";

    package = lib.mkPackageOption pkgs "quasique" { };
    ffmpegPackage = lib.mkPackageOption pkgs "ffmpeg-headless" {
      example = "ffmpeg-full";
    };

    user = lib.mkOption {
      type = types.str;
      default = defaultUser;
      description = "User account under which quasique runs.";
    };
    group = lib.mkOption {
      type = types.str;
      default = defaultUser;
      description = "Group under which quasique runs.";
    };

    workdir = lib.mkOption {
      type = types.path;
      default = "/var/lib/quasique";
      description = "The quasique working directory, where store logs, cache and config.";
    };

    qq = lib.mkOption {
      type = with types; nullOr str;
      default = null;
      description = "The QQ number for quick login.";
    };
    qqPath = lib.mkOption {
      type = with types; nullOr path;
      default = null;
      description = "The path to file contains QQ number for quick login.";
    };

    port = lib.mkOption {
      type = types.port;
      default = 6099;
      description = "The quasique port number. The value gets written to a config file.";
      readOnly = true; # TODO: configurable
    };
    openFirewall = lib.mkEnableOption "Open ports in the firewall for quasique.";
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optional (
      !(builtins.isNull cfg.qq) -> !(builtins.isNull cfg.qqPath)
    ) "If `services.quasique.qq` is set then `services.quasique.qqPath` will be ignored.";

    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };
    users.groups = lib.mkIf (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.quasique = {
      description = "QuasiQue service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ cfg.ffmpegPackage ];

      script =
        let
          quasique = lib.getExe' cfg.package "quasique";
          xvfb-run = lib.getExe' pkgs.xvfb-run "xvfb-run";
          flag =
            if (cfg.qq != null) then
              "--qq ${cfg.qq}"
            else
              (if (cfg.qqPath != null) then "--qq $(cat ${cfg.qqPath})" else "");
        in
        ''
          ${xvfb-run} -a ${quasique} ${flag}
        '';
      environment = {
        NAPCAT_WORKDIR = cfg.workdir;
      };
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "quasique";
        RuntimeDirectory = "quasique";
        LogsDirectory = "quasique";
        Restart = "on-failure";
        WorkingDirectory = cfg.workdir;

        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
