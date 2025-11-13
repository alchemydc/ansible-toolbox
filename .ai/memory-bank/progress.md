# progress.md

## Project Progress

**Purpose:**  
Tracks what works, what's left to build, current status, known issues, and the evolution of project decisions.

---

## Recent Progress (2025-11-13)

### What Works
- `base_server` role now handles Proxmox repository/key management robustly on Proxmox 9 (trixie):
  - Enterprise repo artifacts (.list and .sources) are removed before enabling community repo.
  - Proxmox signing key is downloaded from `https://enterprise.proxmox.com/debian/proxmox-release-{{ proxmox_distro }}.gpg` into `/usr/share/keyrings/proxmox-archive-keyring.gpg`.
  - New `.sources` syntax (`pve-community.sources`) is created for trixie+ hosts; legacy `.list` is used for older distros.
  - `Signed-By` / keyring usage avoids global apt-key additions.
- Inventory issues remedied:
  - Invalid inventory variable keys fixed (e.g. `sdn:mtu` → `sdn_mtu`).
  - Group/host name collisions and problematic characters addressed (e.g. hyphens replaced with underscores where applied).
- `base_server` applies cleanly on zd1 (Proxmox 9) with the updated repo/key flow.

### What's Left to Build / Verify
- Audit `roles/proxmox_hypervisor` to mark repo management as opt-in (`manage_proxmox_repos: false` by default) to avoid duplicate apt changes.
- Run a full dry-run and staged apply on a development/staging proxmox node:
  - Validate pvesm, pve-cluster, pveproxy, and other PVE service operations.
  - Verify ZFS dataset and pvesm add operations succeed as expected.
- Review firewall/iptables -> nftables transition plan for Debian 13 defaults.
- Expand automated inventory validation tests.

### Current Status
- Repo/key workflow implemented and tested in dry-run context.
- Inventory parsing warnings eliminated.
- Next actions require a staging run and proxmox_hypervisor role audit.

### Known Issues
- Some hosts still require manual verification for service-specific behaviors (e.g., cluster join/migration).
- nftables adoption on Debian 13 may require template updates if iptables-legacy is not present.

---

*Update this file as progress is made and verification completes.*
