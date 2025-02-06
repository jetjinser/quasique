{
  description = "QuasiQue";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.treefmt-nix.flakeModule
      ];
      perSystem =
        {
          pkgs,
          system,
          config,
          ...
        }:
        let
          inherit (pkgs) lib callPackage;
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "qq" ];
            overlays = [ self.overlays.default ];
          };
          treefmt.config = {
            projectRootFile = ".git/config";
            package = pkgs.treefmt;
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              statix.enable = true;
            };
          };

          overlayAttrs = {
            inherit (config.packages) napcat-qq quasique;
          };

          apps = rec {
            default = quasique;
            quasique.program = "${config.packages.quasique}";
          };

          packages = rec {
            default = quasique;
            napcat-qq = callPackage ./pkgs/napcat-qq { };
            quasique = callPackage ./pkgs/quasique { inherit napcat-qq; };
          };
        };

      flake = {
        nixosModules.quasique = ./nixos/module.nix;
        nixosModules.default = self.nixosModules.quasique;
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
