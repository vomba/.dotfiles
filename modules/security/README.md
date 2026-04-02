# Security Module

This directory contains security-related configurations and guides.

## Contents

- `gpg.nix` - GPG agent configuration for SSH and commit signing
- `secrets.md` - Guide for setting up sops-nix
- `.sops.yaml.example` - Template for sops configuration

## Secrets Management with SOPS

SOPS (Secrets OPerationS) provides encrypted secrets management integrated with Nix.

### Setup Steps

1. **Install sops-nix** (uncomment in `flake.nix`):
   ```nix
   sops-nix = {
     url = "github:Mic92/sops-nix";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

2. **Generate GPG key** (if not already done):
   ```bash
   gpg --full-generate-key  # RSA 4096
   gpg --list-secret-keys   # Get fingerprint
   ```

3. **Create `.sops.yaml`** in this directory:
   ```yaml
   creation_rules:
     - path_regex: secrets.yaml
       pgp: YOUR_KEY_FINGERPRINT
   ```

4. **Create secrets directory**:
   ```bash
   mkdir -p secrets
   ```

5. **Create encrypted secrets**:
   ```bash
   sops --encrypt secrets/api-keys.yaml > secrets/api-keys.yaml.age
   ```

### Using Secrets in Nix

```nix
{ config, ... }:
{
  # After setting up sops-nix
  secrets.api-keys = {
    sopsFile = ./secrets/api-keys.yaml;
  };

  # Use in configuration
  home.sessionVariables.API_KEY = config.secrets.api-keys.api-key;
}
```

## GPG SSH Agent

The `gpg.nix` module configures GPG agent for SSH authentication:

- SSH_AUTH_SOCK points to gpg-agent's SSH socket
- Automatic agent startup
- Zsh integration
- Pinentry for passphrase entry

## Password Manager Integration

The `scripts/credentials-helper.bash` script supports:
- `pass` - Standard Unix password manager
- `rbw` - Bitwarden CLI replacement

See the script header for detailed usage and security notes.
