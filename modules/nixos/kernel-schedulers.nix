{ inputs, ... }:
let
  kernelSchedulers =
    { pkgs, lib, ... }:
    let
      cachyosKernels = pkgs.cachyosKernels;
      linuxPackagesFor = pkgs.linuxKernel.packagesFor;
      v3Lto =
        pname: kernel:
        kernel.override {
          inherit pname;
          lto = "thin";
          processorOpt = "x86_64-v3";
        };
      schedulerKernels = {
        schedExt = cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
        bore = cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
        bmq = linuxPackagesFor (v3Lto "linux-cachyos-bmq-lto-x86_64-v3" cachyosKernels.linux-cachyos-bmq);
        rt = linuxPackagesFor (
          v3Lto "linux-cachyos-rt-bore-lto-x86_64-v3" cachyosKernels.linux-cachyos-rt-bore
        );
      };
    in
    {
      nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

      # Ryzen 5 3600 is x86-64-v3 (Zen 2); x86-64-v4 and Zen 4 kernels would not boot.
      boot.kernelPackages = schedulerKernels.schedExt;

      services.scx = {
        enable = true;
        scheduler = "scx_lavd";
      };

      specialisation = {
        bore.configuration = {
          boot.kernelPackages = lib.mkForce schedulerKernels.bore;
          services.scx.enable = lib.mkForce false;
        };

        bmq.configuration = {
          boot.kernelPackages = lib.mkForce schedulerKernels.bmq;
          services.scx.enable = lib.mkForce false;
        };

        rt.configuration = {
          boot.kernelPackages = lib.mkForce schedulerKernels.rt;
          services.scx.enable = lib.mkForce false;
        };
      };
    };
in
{
  flake.modules.nixos.kernelSchedulers = kernelSchedulers;
  flake.nixosModules.kernelSchedulers = kernelSchedulers;
}
