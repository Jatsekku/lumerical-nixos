{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.lumerical-dockerized;
in
{
  options.programs.lumerical-dockerized = {
    enable = lib.mkEnableOption "Lumerical";

    package = lib.mkPackageOption pkgs "lumerical-dockerized" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
