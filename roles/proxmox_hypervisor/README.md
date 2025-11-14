# Proxmox Hypervisor Role

Configures Proxmox VE hosts with networking, firewall, storage, and VPN setup.

## Features

- **Proxmox Repository Management** - Automatic trixie+ support with `.sources` format
- **Wireguard VPN** - Data-driven, cluster-wide mesh network
- **nftables Firewall** - Modern Proxmox 9 firewall integration with dynamic NAT rules
- **ZFS Management** - Dataset and quota configuration
- **System Configuration** - Hostname, sysctl, swap setup

## Requirements

- Proxmox 8.1+ (tested on 9.x)
- Debian 12+ (bookworm/trixie)
- `community.proxmox` collection for firewall module
- Ansible 2.13+

## Quick Start

### Wireguard Configuration

All peers defined in `group_vars/proxmox/wireguard.yml`. Private keys stored in encrypted vault.

#### Setup Vault

```bash
# Copy template
cp group_vars/proxmox/vault.yml.template group_vars/proxmox/vault.yml

# Fill in missing private keys from encrypted templates:
ansible-vault view roles/proxmox_hypervisor/templates/wireguard/zd4.conf.j2.encrypted

# Edit and encrypt
ansible-vault encrypt group_vars/proxmox/vault.yml
```

#### Add New Peer

1. Add entry to `wireguard_peers` in `group_vars/proxmox/wireguard.yml`:
```yaml
zd_newhost:
  address: "10.10.68.N"
  public_key: "<wg pubkey output>"
  private_key: "{{ proxmox_wg_private_keys.zd_newhost }}"
  listen_port: 51820
```

2. Add private key to vault:
```bash
ansible-vault edit group_vars/proxmox/vault.yml
# Add: zd_newhost: "<wg genkey output>"
```

3. Deploy:
```bash
ansible-playbook main.yml -i inventory.yml -t wireguard --ask-vault-pass
```

### Firewall Configuration

IP sets and filtering rules in `group_vars/proxmox/firewall.yml`. NAT rules in `templates/pve-nat-rules.j2`.

Deploy with:
```bash
ansible-playbook main.yml -i inventory.yml -t proxmox_firewall
```

## Variables

### Key Defaults

| Variable | Default | Purpose |
|----------|---------|---------|
| `manage_proxmox_repos` | `true` | Manage Proxmox repos (set `false` if handled elsewhere) |
| `proxmox_distro` | — | Required: bookworm, trixie, etc. |
| `wireguard_port` | `51820` | Wireguard listen port |
| `wireguard_network` | `10.10.68.0/24` | VPN subnet |

### Wireguard

- `proxmox_wg_private_keys` - Dict of peer private keys (from vault)
- `wireguard_peers` - Dict of peer configs (address, public_key, endpoint, etc.)

## Tags

| Tag | Purpose |
|-----|---------|
| `wireguard` | Configure Wireguard VPN only |
| `proxmox_firewall` | Configure firewall rules only |
| `proxmox_repos` | Update Proxmox repositories only |
| `interfaces` | Configure network interfaces only |

## Testing

Dry-run before deploying:
```bash
ansible-playbook main.yml -i inventory.yml --check --diff --ask-vault-pass
```

Verify Wireguard on host:
```bash
ssh zd1 wg show wg0
```

## Notes

- Private keys are **encrypted**. Use `--ask-vault-pass` or set `ANSIBLE_VAULT_PASSWORD_FILE`
- Old per-host Wireguard templates archived; now using single dynamic `wg0.conf.j2`
- Firewall rules require Proxmox API credentials (configure in playbook)
- Network changes use `serial: 1` for safety; test on staging first

## License

See LICENSE file.
