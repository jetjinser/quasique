# QuasiQue (QQ)

## Getting Started

> TODO

```nix
{
  inputs = {
    quasique = {
      url = "github:jetjinser/quasique";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ ... }: {
    # ...
  };
}
```

## Overlays

Packages `napcat-qq` and `quasique` are provided.

### Using Overlays

- `inputs.quasique.overlays.quasique`
- `inputs.quasique.overlays.default` (alias for `quasique`)

## NixOS Modules

QuasiQue's service options module.

### Using NixOS Modules

```nix
{
  imports = [
    inputs.quasique.nixosModules.quasique
  ];

  services.quasique = {
    enable = true;
    openFirewall = true;
  };
}
```

## Packages

```sh
> nix build github:jetjinser/quasique#napcat-qq
> nix build github:jetjinser/quasique#quasique
```

## Apps

```sh
> nix run github:jetjinser/quasique#napcat-qq
> nix run github:jetjinser/quasique#quasique
```

## Credits

- This project includes nix scripts to package [NapCatQQ](https://github.com/NapNeko/NapCatQQ).
