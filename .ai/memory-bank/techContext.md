# techContext.md

## Technical Context

**Purpose:**  
Documents technologies used, development setup, technical constraints, dependencies, and tool usage patterns.

---

### Technologies Used
- Ansible (for automation and configuration management)
- Docker (for containerization)
- Zaino (Zcash Indexing Service) - https://github.com/zingolabs/zaino/
- Rust (Zaino is implemented in Rust)
- nftables (native firewalling backend on Proxmox hosts)
- tmux (session multiplexing; deployed on managed hosts)

### Development Setup
- Ansible roles manage service and configuration templates.
- Time Machine server role sets `timemachine_quota` (default: 3T) for both Samba and ZFS quota synchronization.
- Samba configuration uses `server role = standalone server`; smbd is explicitly enabled and started via systemd.
- samba-ad-dc is stopped and masked; nmbd is disabled with service_facts guard; winbind management is removed.
- Handler and notify logic only restart smbd.
- Operator step: ZFS `refquota` must be set manually on Proxmox to match `timemachine_quota`.
- Zaino is run as a Docker container, started via a systemd service template.
- The Zaino configuration is templated at `roles/zcash_node/templates/zindexer.toml.j2` and mounted into the container.
- For local development or testing without TLS, a custom Docker image must be built with the `disable_tls_unencrypted_traffic_mode` feature enabled.
- tmux is provisioned via `roles/base_server` (system package + default config templates and systemd user/session helpers) to improve session resilience and remote troubleshooting.
- IPv6 is explicitly disabled for Proxmox 9 guests (trixie) where required; applied via sysctl/cloud-init templates in `roles/proxmox_hypervisor` and `roles/base_server` using `net.ipv6.conf.all.disable_ipv6=1` and `net.ipv6.conf.default.disable_ipv6=1`.

### Technical Constraints
- Official Zaino Docker images enforce TLS unless built with the `disable_tls_unencrypted_traffic_mode` feature.
- Setting `grpc_tls = false` in the config is not sufficient to disable TLS enforcement.
- Custom Docker build is required to disable TLS for non-private addresses.
- The `proxmox-firewall` abstraction proved brittle when driven by Ansible and lacks reliable DNAT support; NAT/DNAT are handled via native `nftables` templates instead.

### Dependencies
- Zaino Docker image (official or custom)
- Ansible roles and templates
- Rust toolchain (for custom Zaino builds)
- nftables and kernel nft support on Proxmox hosts

### Tool Usage Patterns
- Use Ansible to manage Samba configuration, service state, and quota variables for Time Machine backups.
- Use Ansible to manage Docker containers and configuration files.
- Zaino configuration is managed via Jinja2 template and mounted into the container at runtime.
- tmux is installed/configured via `roles/base_server` to provide consistent session management across hosts.
- Apply IPv6-disable via sysctl templates or cloud-init snippets for guests where required.
- Render NAT/DNAT rules via `roles/proxmox_hypervisor/templates/nftables.conf.j2` and validate with `nft -c -f` and `nft list ruleset`.

---

