# NixOS config

Flake-based NixOS + Home Manager configuration for the `nixbook` laptop.

```
├── flake.nix
├── hosts
│   ├── common.nix
│   ├── nixbook/            # host config, hardware config
│   └── users/conor/        # home.nix, jj configs, secrets.yaml, etc.
├── lib/mkSystem.nix
├── .sops.yaml              # sops creation rules (age public keys)
└── Taskfile.yml
```

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using
[age](https://github.com/FiloSottile/age) encryption. The age key is derived
from a dedicated SSH key named **`nixbook-sops`**.

- Encrypted file: `hosts/users/conor/secrets.yaml`
- Rules and public key: `.sops.yaml`
- Decryption (at login, via Home Manager): `~/.ssh/nixbook-sops`

The encrypted file is safe to commit. It is **useless without the private key**,
so the private key must be backed up (see below).

## The `nixbook-sops` SSH key

| File                        | Purpose                                      |
| --------------------------- | -------------------------------------------- |
| `~/.ssh/nixbook-sops`       | Private key (ed25519, **no passphrase**)     |
| `~/.ssh/nixbook-sops.pub`   | Public key (optional, used to derive age pubkey) |

Requirements:

- Must be **ed25519**. `ssh-to-age` does not support other key types here.
- Must have **no passphrase**, because sops-nix decrypts non-interactively at activation.
- Must be named exactly `nixbook-sops`. `home.nix` references this path:

  ```nix
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/nixbook-sops" ];
  ```

### Where the backups live

- USB drive: `<fill in label/location>`
- Bitwarden: `<fill in item name>` (private key stored as an SSH key item or secure note)

Keep at least one backup offline. If the private key is lost, the contents of
`secrets.yaml` are unrecoverable and you must re-create the secrets from scratch.

## Bootstrapping a new machine

Place the key **before** the first `nixos-rebuild switch` if you can. If you
rebuild first, the system builds fine but the secrets won't decrypt until the
key is in place (see step 4).

### 1. Create the SSH directory

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

### 2. Copy the private key into place

**From a USB drive:**

```bash
# find and mount the drive (adjust device name)
lsblk
sudo mkdir -p /mnt/usb
sudo mount /dev/sdX1 /mnt/usb

cp /mnt/usb/nixbook-sops ~/.ssh/nixbook-sops

sudo umount /mnt/usb
```

**From Bitwarden:**

Either copy the key from the Bitwarden app or web vault and paste it into the
file, or use the CLI:

```bash
nix shell nixpkgs#bitwarden-cli
bw login
export BW_SESSION="$(bw unlock --raw)"

# if stored as a secure note:
bw get notes "<item name>" > ~/.ssh/nixbook-sops

# if stored as an attachment:
bw get attachment nixbook-sops --itemid "<item id>" --output ~/.ssh/nixbook-sops
```

Make sure the file ends with a trailing newline and keeps the
`-----BEGIN OPENSSH PRIVATE KEY-----` / `-----END OPENSSH PRIVATE KEY-----` lines intact.

### 3. Fix permissions and regenerate the public key

```bash
chmod 600 ~/.ssh/nixbook-sops
ssh-keygen -y -f ~/.ssh/nixbook-sops > ~/.ssh/nixbook-sops.pub
chmod 644 ~/.ssh/nixbook-sops.pub
```

If `ssh-keygen -y` prompts for a passphrase, the key is the wrong one. It must
be passphrase-less.

### 4. Verify, then rebuild

Check that the derived age public key matches the one in `.sops.yaml`:

```bash
nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/.ssh/nixbook-sops.pub
```

Check that decryption works:

```bash
SOPS_AGE_KEY="$(nix shell nixpkgs#ssh-to-age -c ssh-to-age -private-key -i ~/.ssh/nixbook-sops)" \
  nix shell nixpkgs#sops -c sops -d hosts/users/conor/secrets.yaml
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#nixbook
```

If the key was placed after the rebuild, restart the Home Manager sops service
instead of logging out:

```bash
systemctl --user restart sops-nix
ls /run/user/$(id -u)/secrets/
```

## Editing secrets

The `sops` CLI needs the age key to edit. Create it once from the SSH key:

```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#ssh-to-age -c ssh-to-age -private-key -i ~/.ssh/nixbook-sops \
  > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Then edit:

```bash
sops hosts/users/conor/secrets.yaml
```

Remember to `git add` (or track in jj) the file, or the flake won't see it.

## Rotating the key

1. Generate a new key: `ssh-keygen -t ed25519 -N "" -f ~/.ssh/nixbook-sops-new`
2. Get its age public key: `ssh-to-age < ~/.ssh/nixbook-sops-new.pub`
3. Add the new age key to `.sops.yaml` next to the old one.
4. Re-encrypt: `sops updatekeys hosts/users/conor/secrets.yaml`
5. Swap the new key into `~/.ssh/nixbook-sops`, rebuild, confirm secrets decrypt.
6. Remove the old key from `.sops.yaml`, run `sops updatekeys` again, and update backups.

## Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `no identity matched any of the recipients` | Age pubkey in `.sops.yaml` doesn't match `nixbook-sops`; re-check step 4 |
| `sops-nix` service fails at login | Key missing, wrong name, or wrong permissions (must be `600`) |
| `ssh-to-age` errors on the key | Key isn't ed25519, or has a passphrase |
| Secret files missing in `/run/user/<uid>/secrets/` | Service hasn't run; restart `sops-nix` as above |
| Flake can't find `secrets.yaml` | File isn't tracked by git/jj |
