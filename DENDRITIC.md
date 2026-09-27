# Dendritic Pattern Guideline

Every file under `modules/` is a flake-parts module that publishes named
**aspects** (one concern each). Hosts explicitly import the aspects they use;
importing an aspect is what enables it.

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
```

`import-tree` loads every file except paths prefixed with `_`.

## 1. Define an aspect

Bind the module once and publish it under both names:

```nix
# modules/nixos/networking.nix
{ inputs, ... }:
let
  networking = { pkgs, ... }: {
    imports = [ inputs.some-flake.nixosModules.default ]; # external deps here
    networking.networkmanager.enable = true;
  };
in
{
  flake.modules.nixos.networking = networking; # registry for external consumers
  flake.nixosModules.networking = networking;  # what hosts in this flake import
}
```

- Name aspects after the capability (`networking`, `stylix`, `kernelSchedulers`),
  not the file path.
- Keep it self-contained: set its options and import its external flake modules.
- No `my.<aspect>.enable` options. Import it or don't.

## 2. Compose aspects

An aspect may import other aspects it directly depends on:

```nix
{ self, ... }:
{
  flake.nixosModules.desktop = {
    imports = [ self.nixosModules.networking self.nixosModules.stylix ];
  };
}
```

Use `self.nixosModules.<name>`. Never read `inputs.self.modules` or
`config.flake.modules` while building this flake's outputs.

## 3. Assemble a host

A host file builds the system from aspects plus one host-only aspect:

```nix
# modules/hosts/desktop/default.nix
{ self, inputs, ... }:
{
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };   # plus unstable-pkgs; nothing else
    modules = [
      self.nixosModules.nixosDefaults
      self.nixosModules.kernelSchedulers
      self.nixosModules.desktopConfiguration
    ];
  };

  flake.nixosModules.desktopConfiguration = {
    imports = [ ./_hardware-configuration.nix ];
    networking.hostName = "desktop";
  };
}
```

- Host aspect holds only host facts: hardware, filesystems, bootloader device,
  hostname, host-specific drivers. Anything reusable becomes its own aspect.
- Shared baseline lives in a named aspect (`nixosDefaults`, `darwinDefaults`),
  imported explicitly — never a catch-all that imports the whole catalogue.
- `specialArgs` carries only cross-cutting values (`inputs`, `unstable-pkgs`),
  not ad-hoc configuration.

## 4. Migrate existing config

1. Create the aspect with the paired exports.
2. Move the config verbatim — no value changes during a structural move.
3. Replace the inline config in the host with `self.nixosModules.<name>`.
4. Ensure each host imports an aspect once, then evaluate before the next step:

   ```sh
   nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
   ```

## Invariants: `kernelSchedulers`

Preserve on any refactor:

- `nix-cachyos-kernel` input and its release overlay stay applied.
- Default kernel: CachyOS x86-64-v3 ThinLTO with `services.scx.scheduler = "scx_lavd"`.
- Specialisations `bore` (x86-64-v3 ThinLTO) and `rt` (stock
  `linuxPackages-cachyos-rt-bore`; no cached LTO/v3 variant exists) both disable
  `services.scx`. BMQ is unavailable: its patch doesn't apply upstream.
- NVIDIA package comes from `config.boot.kernelPackages` so every kernel gets a
  matching module.

## Review checklist

- Host imports every active capability explicitly?
- Each aspect imports only its direct dependencies?
- No host facts in reusable aspects?
- Aspect movable to another file without touching consumers?
- `drvPath` eval succeeds for every changed host?

## References

- [Dendritic pattern overview](https://britter.dev/blog/2026/05/11/exploring-the-dendritic-nix-pattern/)
- [import-tree](https://github.com/denful/import-tree)
