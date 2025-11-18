# Proxmox Hypervisor Role

Configures Proxmox VE hosts with networking, firewall, storage, and VPN setup.

## Features

- **Proxmox Repository Management** - Automatic trixie+ support with `.sources` format
- **Wireguard VPN** - Data-driven, cluster-wide mesh network with safe restart & rollback
- **nftables Firewall** - Modern Proxmox 9 firewall integration with dynamic NAT rules
- **ZFS Management** - Dataset and quota configuration
- **System Configuration** - Hostname, sysctl, swap setup
- **Swap Management** - Idempotent multi-disk swap partition creation

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

### Firewall variables

Example and expected formats for `group_vars/proxmox/firewall.yml`:

```yaml
# nftables_ipsets: dict mapping set_name -> list of CIDRs (strings)
nftables_ipsets:
  admin_network:
    - "10.10.10.0/24"

# nftables_input_rules: list of rule objects:
nftables_input_rules:
  - comment: "Allow loopback"
    rule: "iifname lo accept"

# nftables_dnat_rules: list of DNAT mappings (cluster-wide)
nftables_dnat_rules:
  - name: "HTTP to ingress"
    protocol: "tcp"
    host_port: 80
    workload_ip: "{{ docker_ingress_host }}"
    workload_port: 80

# Policies: "accept" | "drop" etc.
nftables_input_policy: "drop"
nftables_forward_policy: "accept"
nftables_output_policy: "accept"
```

Notes:
- IP set references in rules use `@set_name` (e.g. `ip saddr @admin_network accept`).
- `workload_ip` may be a templated inventory variable and will be rendered by the template.
- Keep rule fragments valid for insertion into an `inet filter` chain.

The repo config programmatically sets host alternatives to prefer the *-nft wrapper binaries (see `roles/proxmox_hypervisor/tasks/configure_firewall.yml`) so legacy iptables kernel modules are not loaded by default.

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

## Recent Changes

### Wireguard Handler
- Moved from playbook level to role-level with proper scoping
- Implements safe restart with automatic rollback on failure
- Backs up config before restart; restores if connectivity lost
- Handler: `restart proxmox_wireguard` (unique name to avoid conflicts)

### Wireguard Template
- Removed hardcoded naming conventions
- Endpoint resolution: explicit config → `<peer>_public_ip` variable → no endpoint
- Works with any peer naming scheme

### Swap Configuration
- Now idempotent: checks for existing swap before creating
- Detects swap by `fstype: linux-swap` instead of hardcoding partition names
- Dynamic partition numbering per disk
- Multi-disk support with per-disk scoping
- No longer runs on every playbook execution

## System Configuration

### sysctl Settings (BGP EVPN & VXLAN)

This role disables reverse path filtering (`rp_filter=0`) and enables IP forwarding (`ip_forward=1`):

- **rp_filter=0** - EVPN routes traffic asymmetrically (in one interface, out another). Strict RPF mode drops these packets; disabled globally.
- **ip_forward=1** - Required to route between VXLAN tunnel interfaces and physical NICs. Essential for inter-VNET communication.

These settings are required for BGP EVPN SDN to function properly in Proxmox 9+.

## Notes

- Private keys are **encrypted**. Use `--ask-vault-pass` or set `ANSIBLE_VAULT_PASSWORD_FILE`
- Wireguard template is naming-scheme agnostic; uses explicit endpoints first, then inventory variables
- Firewall rules require Proxmox API credentials (configure in playbook)
- Network changes use `serial: 1` for safety; test on staging first
- Wireguard config corruption no longer leaves host unreachable (auto-rollback on failed restart)
- sysctl parameters for BGP EVPN are applied automatically; documented in configure_sysctl.yml

## License

See LICENSE file.
