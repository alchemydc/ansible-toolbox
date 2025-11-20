# systemPatterns.md

## System Patterns

**Purpose:**  
Documents system architecture, key technical decisions, design patterns, component relationships, and critical implementation paths.

---

### System Architecture

**Proxmox Hypervisor Cluster:**
- Proxmox nodes  + external admin clients  connected via Wireguard mesh VPN 
- Firewalling managed cluster-wide via Proxmox API + nftables backend.
- SDN subnets (anycast_subnets) for workload communication and prometheus monitoring.

### Key Technical Decisions
- **Firewalling:** Prefer native `nftables` for NAT/DNAT and node-local rules (templates: `roles/proxmox_hypervisor/templates/nftables.conf.j2`). Cluster-wide filtering may be managed via the Proxmox API when stable, but we will not rely on the `proxmox-firewall` abstraction because it proved brittle when driven by Ansible and lacks reliable DNAT support which is critical for our use case.
- **Wireguard:** Single data-driven configuration in `group_vars/proxmox/wireguard.yml`; template (`wg0.conf.j2`) generates per-host configs automatically.
- **Vault:** Dictionary-based structure (`vault_proxmox_wg_private_keys.hostname`) for organized key management.
- **Zaino:** Deployed as Docker container; TLS enforcement requires custom build with `disable_tls_unencrypted_traffic_mode`.
- **Samba (Time Machine):** Fileserver-only with smbd-only service config, ZFS quota sync, fruit:locking=none for stability.

### Design Patterns
- **Data-driven configuration:** All peer/rule definitions in YAML dicts; templates generate from single source (7x fewer files).
- **Fileserver-only Samba:** Only smbd enabled; AD DC stopped/masked; NetBIOS disabled; winbind removed.
- **Conditional service management:** All service tasks use service_facts to avoid errors for missing units.
- **Network safety:** Template tasks use `backup: yes`; handlers implement rollback via `wait_for_connection` + restore.
- **Quota synchronization:** Single variable (`timemachine_quota` or `wireguard_port`) drives all related configs.
- **Vault scoping:** Encrypted keys in `group_vars/proxmox/vault.yml`; reference via `{{ vault_proxmox_wg_private_keys.hostname }}`.
- **Firewalling approach:** Prefer native `nftables` files for NAT/DNAT rendered from templates and use the Proxmox API for cluster-wide filtering only when reliable. Avoid the proxmox-firewall abstraction for DNAT-heavy workloads due to Ansible brittleness and feature gaps.

### Component Relationships
- **Proxmox Hypervisor Role** → configures repos, networking, firewall, Wireguard, ZFS, sysctl.
- **Base Server Role** → centralized Proxmox repo management (optional via `manage_proxmox_repos` flag).
- **Firewalling:** Cluster rules via API (proxmox_firewall module) + node-local NAT rules (nftables files).
- **Wireguard:** All peers in one YAML dict; vault holds private keys; single template generates all configs.

### Critical Implementation Paths
- **Wireguard Setup:**
  1. Fill `group_vars/proxmox/wireguard.yml` with peer defs (address, public_key).
  2. Populate `group_vars/proxmox/vault.yml` with `vault_proxmox_wg_private_keys` dict.
  3. Deploy: `ansible-playbook main.yml -i inventory.yml -t wireguard --ask-vault-pass`.
  4. Template auto-generates `wg0.conf` for each host based on `inventory_hostname`.

- **Firewall Setup:**
  1. Define IP sets and rules in `group_vars/proxmox/firewall.yml`.
  2. NAT rules in `roles/proxmox_hypervisor/templates/pve-nat-rules.j2`.
  3. Deploy: `ansible-playbook main.yml -i inventory.yml -t proxmox_firewall` (requires API credentials).
  4. Logs via `journalctl -fu proxmox-firewall` (journald, not syslog).

- **Network Config Rollback:**
  1. Template task sets `backup: yes` → creates `/etc/network/interfaces.backup`.
  2. Handler uses `net_tpl.backup_path` to restore if restart fails.
  3. Always use `--check --diff` before deploying; test on one node first.

- **To disable TLS in Zaino:** Fork repo, build with `disable_tls_unencrypted_traffic_mode` feature; official image does not include this.
- **Zaino config:** Template at `roles/zcash_node/templates/zindexer.toml.j2`; mounted into container at runtime.
---

