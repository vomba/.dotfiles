# SOPS-Nix Secrets Management
#
# This directory provides secrets management using sops-nix
# https://github.com/Mic92/sops-nix
#
# SETUP INSTRUCTIONS:
# ===================
#
# 1. Install sops-nix in your flake.nix inputs:
#    sops-nix = {
#      url = "github:Mic92/sops-nix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#
# 2. Add to your home.nix or darwin.nix imports:
#    sops-nix.homeManagerModules.sops
#
# 3. Create a .sops.yaml configuration file in this directory:
#    creation_rules:
#      - path_regex: secrets.yaml
#        pgp: >-
#          YOUR_KEY_FINGERPRINT
#
# 4. Generate GPG key for secrets (if not already done):
#    gpg --full-generate-key  # Use RSA 4096
#
# 5. Create your secrets.yaml file:
#    secrets:
#      my-api-key: "your-secret-value"
#      another-secret: "another-value"
#
# 6. Encrypt the secrets file:
#    sops --encrypt secrets.yaml > secrets.yaml.age
#    rm secrets.yaml  # Keep only encrypted version
#
# 7. Reference secrets in your Nix config:
#    sops.variables.MY_API_KEY
#
# IMPORTANT SECURITY NOTES:
# =========================
# - NEVER commit secrets.yaml to git (it's in .gitignore)
# - Only commit encrypted .age files
# - Keep your private GPG key secure (backup recommended)
# - Rotate secrets periodically
# - Use separate GPG keys for different environments
#
# EXAMPLE .sops.yaml:
# ===================
# creation_rules:
#   # Personal secrets (use your personal GPG key)
#   - path_regex: personal/secrets.yaml
#     pgp: >-
#       ABC123DEF456...
#
#   # Work secrets (use work GPG key)
#   - path_regex: work/secrets.yaml
#     pgp: >-
#       WORKKEY123...
#
#   # Age encryption (alternative to GPG)
#   - path_regex: .+/secrets.yaml
#     age: >-
#       age1...
