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
      
      rawg = {
        enable = mkEnableOption (lib.mdDoc "Enable RAWG api integration.");
        apiKey = mkOption {
          
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gamevault = {
      description = "Backend for the self-hosted gaming platform for alternatively obtained games";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
    };

    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = mkIf (cfg.enable) true;
    };

    users.groups.${cfg.group}.= {};

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [8080];
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [{
        name = ${cfg.user};
        ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
      }];
    };

    systemd.services.gamevault = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.gamevault}/bin/gamevault";
        User = cfg.user;
        Group = cfg.group;
      };
      environment = {
        DB_HOST = "localhost";
        DB_USERNAME = "gamevault";
        SERVER_ADMIN_USERNAME = "admin";
        RAWG_API_KEY = mkIf (cfg.rawg.enable) "${cfg.rawg.apiKey}"
      };
    };
  };

  meta.maintainers = with lib.maintainers; [michaelBelsanti];
}
