{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.gamevault;
in {
  options = {
    services.gamevault = {
      enable = mkEnableOption (lib.mdDoc "gamevault Media Server");

      user = mkOption {
        type = types.str;
        default = "gamevault";
        description = lib.mdDoc "User account under which gamevault runs.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.gamevault;
        defaultText = literalExpression "pkgs.gamevault";
        description = lib.mdDoc ''
          gamevault package to use.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "gamevault";
        description = lib.mdDoc "Group under which gamevault runs.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open Gamevaults default ports in the firewall.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gamevault = {
      description = "Backend for the self-hosted gaming platform for alternatively obtained' games";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
    };

    users.users = mkIf (cfg.user == "gamevault") {
      gamevault = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "gamevault") {
      gamevault = {};
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [8080];
    };
  };

  meta.maintainers = with lib.maintainers; [michaelBelsanti];
}
