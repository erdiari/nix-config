{ pkgs, ... }:
{
  # MSI B350M BAZOOKA: expose the NCT6795D fan controller.
  boot.kernelModules = [ "nct6775" ];
  environment.systemPackages = [ pkgs.lm_sensors ];

  systemd.services.server-fan-curve = {
    description = "Configure the server's hardware-managed fan curves";
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
        trap 'echo 0 > "$hwmon/pwm2_enable"; echo 0 > "$hwmon/pwm3_enable"; echo 0 > "$hwmon/pwm4_enable"' EXIT
        echo 0 > "$hwmon/pwm2_enable"
        echo 0 > "$hwmon/pwm3_enable"
        echo 0 > "$hwmon/pwm4_enable"

        # Program a 5-point Smart Fan IV table: temp_sel 7 is Tctl (Ryzen
        # 1600X Tdie + 20 C), exposed on this board as SMBUSMASTER 0. Every
        # fan is allowed to stop completely under minimal/idle load instead
        # of BIOS's fixed minimums, then ramps up gradually so the box stays
        # inaudible until it's actually working.
        configure_pwm() {
          pwm="$1"
          echo 1 > "$hwmon/pwm''${pwm}_mode"
          echo 7 > "$hwmon/pwm''${pwm}_temp_sel"
          echo "$6" > "$hwmon/pwm''${pwm}_auto_point5_temp"
          echo "$5" > "$hwmon/pwm''${pwm}_auto_point4_temp"
          echo "$4" > "$hwmon/pwm''${pwm}_auto_point3_temp"
          echo "$3" > "$hwmon/pwm''${pwm}_auto_point2_temp"
          echo "$2" > "$hwmon/pwm''${pwm}_auto_point1_temp"
          echo "''${11}" > "$hwmon/pwm''${pwm}_auto_point5_pwm"
          echo "''${10}" > "$hwmon/pwm''${pwm}_auto_point4_pwm"
          echo "$9" > "$hwmon/pwm''${pwm}_auto_point3_pwm"
          echo "$8" > "$hwmon/pwm''${pwm}_auto_point2_pwm"
          echo "$7" > "$hwmon/pwm''${pwm}_auto_point1_pwm"
        }

        # Smart Fan IV (mode 5) has no hardware start-boost or stop-debounce
        # of its own (those pwm_start/pwm_floor/pwm_stop_time attributes
        # only apply to Thermal Cruise mode 2); a fan commanded straight
        # from 0% to a low duty cycle can fail to overcome static friction
        # and silently never spin up. So each curve jumps from 0% to a
        # spin-safe ~43% within a narrow 2 C band instead of ramping
        # through the dead zone, then climbs gently from there.

        # CPU fan: off below 44 C, kicks to 43% by 46 C, 100% at 95 C.
        configure_pwm 2 44000 46000 60000 80000 95000 0 110 150 200 255
        # Case fan (front intake): off below 48 C, kicks to 43% by 50 C;
        # starts after the CPU fan has already stepped up once.
        configure_pwm 3 48000 50000 65000 82000 95000 0 110 150 200 255
        # Case fan (rear exhaust): off below 52 C, kicks to 43% by 54 C;
        # staggered a notch above the intake fan so both don't kick in at
        # once.
        configure_pwm 4 52000 54000 68000 84000 95000 0 110 150 200 255

        # Smart Fan IV runs in the controller, without a userspace daemon.
        echo 5 > "$hwmon/pwm2_enable"
        echo 5 > "$hwmon/pwm3_enable"
        echo 5 > "$hwmon/pwm4_enable"
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
        echo 0 > "$hwmon/pwm3_enable"
        echo 0 > "$hwmon/pwm4_enable"
      done
    '';
  };
}
