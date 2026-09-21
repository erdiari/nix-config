{ pkgs, ... }:
{
  # MSI B350M BAZOOKA: expose the NCT6795D fan controller.
  boot.kernelModules = [ "nct6775" ];
  environment.systemPackages = [ pkgs.lm_sensors ];

  systemd.services.server-fan-curve = {
    description = "Configure the server's hardware-managed CPU fan curve";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      for hwmon in /sys/class/hwmon/hwmon*; do
        [ "$(cat "$hwmon/name")" = nct6795 ] || continue
        [ "$(cat "$hwmon/temp7_label")" = 'SMBUSMASTER 0' ]

        # Keep full speed while programming; failures also restore full speed.
        trap 'echo 0 > "$hwmon/pwm2_enable"' EXIT
        echo 0 > "$hwmon/pwm2_enable"
        echo 1 > "$hwmon/pwm2_mode"
        echo 7 > "$hwmon/pwm2_temp_sel"

        # This source is Tctl: Ryzen 1600X Tdie + 20 C.
        # 60% at 30 C die, rising to 100% at 70 C die.
        echo 95000 > "$hwmon/pwm2_auto_point5_temp"
        echo 90000 > "$hwmon/pwm2_auto_point4_temp"
        echo 80000 > "$hwmon/pwm2_auto_point3_temp"
        echo 65000 > "$hwmon/pwm2_auto_point2_temp"
        echo 50000 > "$hwmon/pwm2_auto_point1_temp"
        echo 255 > "$hwmon/pwm2_auto_point5_pwm"
        echo 255 > "$hwmon/pwm2_auto_point4_pwm"
        echo 217 > "$hwmon/pwm2_auto_point3_pwm"
        echo 179 > "$hwmon/pwm2_auto_point2_pwm"
        echo 153 > "$hwmon/pwm2_auto_point1_pwm"

        # Smart Fan IV runs in the controller, without a userspace daemon.
        echo 5 > "$hwmon/pwm2_enable"
        trap - EXIT
        exit 0
      done
      echo 'NCT6795 fan controller not found' >&2
      exit 1
    '';
    preStop = ''
      for hwmon in /sys/class/hwmon/hwmon*; do
        [ "$(cat "$hwmon/name")" = nct6795 ] || continue
        echo 0 > "$hwmon/pwm2_enable"
      done
    '';
  };
}
