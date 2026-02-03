{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.falcond;
in
{
  options.services.falcond = {
    enable = lib.mkEnableOption "Falcon Daemon service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.falcond;
      defaultText = lib.literalExpression "pkgs.falcond";
      description = ''
        Falcon Daemon package.
      '';
    };

    configText = lib.mkOption {
      type = lib.types.lines;
      default = ''
        enable_performance_mode = true
        scx_sched = none
        scx_sched_props = default
        vcache_mode = none
        profile_mode = none
      '';
      description = ''
        Configuration for Falcon Daemon.
      '';
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      description = ''
        Game profiles for Falcon Daemon.
        Each profile defines settings for a specific game or application.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "falcond/config.conf".text = cfg.configText;
    }
    // lib.mapAttrs' (name: profileText: {
      name = "falcond/profiles/user/${name}.conf";
      value.text = profileText;
    }) cfg.profiles;

    systemd.services.falcond = {
      description = "Falcon Daemon Service";

      after = [ "multi-user.target" ];
      wants = [ "graphical.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        User = "root";
        Restart = "on-failure";
      };

      wantedBy = [ "graphical.target" ];
    };
  };
}
