# Dendritic Configuration Guideline

## Purpose

Organize Nix configuration as named, composable aspects. A host explicitly imports
exactly the aspects it uses. Importing an aspect enables it; do not create a
separate `enable` option merely to gate configuration.

The root flake remains the discovery mechanism:

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
```

`import-tree` discovers files. `flake.modules.<class>` publishes the aspect registry
for external consumers. During this flake's own output construction, hosts use
`flake.nixosModules`; both exports bind to the same aspect value.

## Aspect contract

Define one named aspect for one concern:

```nix
{ ... }:
{
  flake.modules.nixos.networking = {
    networking.networkmanager.enable = true;
  };
}
```

- Name aspects for capabilities, not their path: `networking`, `stylix`,
  `kernelSchedulers`, `desktopUser`.
- Keep an aspect self-contained: declare the NixOS options that implement its
  concern and import its direct dependencies.
- Importing an aspect is the only activation mechanism. Do not add a parallel
  `my.<aspect>.enable` switch.
- An aspect may import another aspect by registry name:

  ```nix
  { inputs, ... }:
  {
    flake.modules.nixos.desktop = {
      imports = with inputs.self.modules.nixos; [
        networking
        stylix
      ];
    };
  }
  ```

- Do not import the whole module catalogue from a central dispatcher. A broad
  default import hides dependencies and defeats the pattern.

## Baselines and hosts

Use a named `base` aspect for universally required settings. `default.nix` may
be a local file entry point, but it is not a magic global configuration.

A host is an assembler. It creates the NixOS system and imports its selected
aspects by registry name:

```nix
{ self, inputs, ... }:
{
  flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      self.nixosModules.base
      self.nixosModules.desktop
      self.nixosModules.kernelSchedulers
      self.nixosModules.desktopHost
    ];
  };

  flake.nixosModules.desktopHost = {
    imports = [ ./_hardware-configuration.nix ];
    networking.hostName = "desktop";
  };
}
```

Host-only facts stay in the host aspect: hardware imports, filesystems, boot
loader device, hostname, and host-specific driver choices. Reusable behavior
belongs in capability aspects.

## Imports and inputs

- Define an aspect once with a local `let` binding, then publish that same value
  as both `flake.modules.nixos.<name>` and `flake.nixosModules.<name>`.
- While constructing a host in this flake, import
  `self.nixosModules.<name>`. Do not access `inputs.self.modules` or
  `config.flake.modules` from the in-progress output fixed point.
- Import an external flake module inside the aspect that consumes it.
- Keep `specialArgs` limited to cross-cutting values such as `inputs` and the
  existing `unstable-pkgs`; do not use it as an untyped configuration channel.
- Files and directories prefixed with `_` remain private implementation details
  and are ignored by `import-tree`. Hardware-generated files belong there.

## Existing scheduler implementation

The current desktop scheduler implementation is behavior to preserve during any
structural migration:

- `nix-cachyos-kernel` remains a flake input and its release overlay remains
  applied.
- The normal desktop kernel remains the x86-64-v3 ThinLTO CachyOS kernel with
  `services.scx.scheduler = "scx_lavd"`.
- The `bore` and `rt` specialisations remain available and disable
  `services.scx`; the BMQ variant is unavailable because CachyOS's current
  BMQ patch does not apply to its packaged kernel source.
- NVIDIA continues to obtain its package from
  `config.boot.kernelPackages`, so every selected kernel gets a matching module.

Extract this implementation into a `kernelSchedulers` aspect only as a pure
move. The desktop host must explicitly import it. Do not change scheduler,
kernel, LTO, ISA, or specialisation behavior while changing structure.

## Migration rules

1. Bind a new aspect once in its defining module.
2. Publish it as both `flake.modules.nixos.<name>` and
   `flake.nixosModules.<name>`.
3. Move the existing configuration into that aspect without changing values.
4. Replace the host's inline configuration with a
   `self.nixosModules.<name>` import.
5. Evaluate that host before migrating the next one. A host must import only
   one copy of an aspect.

This preserves the current working implementation while migration proceeds
incrementally. The paired exports are a registry adapter, not two activated
modules: hosts import only the `nixosModules` value.

## Review checklist

- Does the host import every active capability explicitly?
- Does each aspect import only its direct dependencies?
- Can the aspect move to another file without changing consumers?
- Are host facts absent from reusable aspects?
- Did the migration retain all kernel specialisations and matching NVIDIA
  package selection?
- Does `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
  succeed for every changed host?

## References

- [Dendritic pattern overview](https://britter.dev/blog/2026/05/11/exploring-the-dendritic-nix-pattern/)
- [import-tree dendritic flake-parts usage](https://github.com/denful/import-tree)
