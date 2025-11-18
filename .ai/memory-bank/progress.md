# progress.md

## Project Progress

**Purpose:**  
Tracks what works, what's left to build, current status, known issues, and the evolution of project decisions.

---

## Recent Progress (2025-11-18)

### What Works
- `base_server` role now handles Proxmox repository/key management robustly on Proxmox 9 (trixie):
  - Enterprise repo artifacts (.list and .sources) are removed before enabling community repo.
  - Proxmox signing key is downloaded from `https://enterprise.proxmox.com/debian/proxmox-release-{{ proxmox_distro }}.gpg` into `/usr/share/keyrings/proxmox-archive-keyring.gpg`.
  - New `.sources` syntax (`pve-community.sources`) is created for trixie+ hosts; legacy `.list` is used for older distros.
  - `Signed-By` / keyring usage avoids global apt-key additions.

- `proxmox_hypervisor` role now includes standalone repo management and safer networking:
  - Added `manage_proxmox_repos: true` in `roles/proxmox_hypervisor/defaults/main.yml` to enable repo management by default when the role runs standalone.
  - `roles/proxmox_hypervisor/tasks/configure_proxmox_repos.yml` refactored to mirror `base_server` logic.

- Firewall migration to native nftables completed:
  - Centralized filtering and IP sets in `group_vars/proxmox/firewall.yml`.
  - Cluster-wide DNAT rules moved into `group_vars/proxmox/firewall.yml` (cluster scope).
  - Template `roles/proxmox_hypervisor/templates/nftables.conf.j2` generates `/etc/nftables.conf` and includes both FILTER (inet) and NAT (ip) tables.
  - `roles/proxmox_hypervisor/tasks/configure_firewall.yml` now installs/enables `nftables`, deploys `/etc/nftables.conf`, masks Proxmox/pve firewall services, and validates the configuration with `nft -c -f`.
  - Handler updated to reload `nftables` via systemd.
  - DNAT examples were activated cluster-wide; SNAT rules already rendered correctly.

- Alternatives adjusted to prefer nft wrappers:
  - The system now documents preferring `*-nft` wrappers for `iptables`, `ip6tables`, `arptables`, and `ebtables`.
  - This avoids loading legacy iptables kernel modules (xt_* families) and ensures the nft backend is used by default.

### Current Status (as of 2025-11-18)
- **Firewall:** Migrated from iptables to nftables; centralized rules in `group_vars/proxmox/firewall.yml`; NAT rules in `roles/proxmox_hypervisor/templates/nftables.conf.j2`.
  - DNAT rules: declared cluster-wide and rendered by the template.
  - SNAT rules: implemented and rendering correctly.
  - Services `proxmox-firewall`, `pve-firewall`, and `netfilter-persistent` are disabled/masked by tasks to avoid auto-start via dependencies.
  - Validation: deployed config validated with `nft -c -f /etc/nftables.conf` on hosts.
- **Alternatives:** Documentation updated to recommend the following commands on hosts where alternatives are managed:
  - `update-alternatives --set iptables /usr/sbin/iptables-nft`
  - `update-alternatives --set ip6tables /usr/sbin/ip6tables-nft`
  - `update-alternatives --set arptables /usr/sbin/arptables-nft`
  - `update-alternatives --set ebtables /usr/sbin/ebtables-nft`
  - Verification: `update-alternatives --display iptables` and `lsmod | grep -E 'xt_|iptable_'` (should not show xt_* iptables modules when nft wrappers are active).

### What's Left to Build / Verify
- Firewall idempotency and verification:
  - Run playbook 2-3x on a staging node to confirm no duplicate rules are created.
  - Verify DNAT rules appear in `/etc/nftables.conf` and are active with `nft list ruleset`.
  - Confirm no legacy iptables kernel modules are loaded after switching alternatives.
- Monitoring and rollout:
  - Test cluster for 24-48 hours after deployment to confirm no lockouts or service regressions.
  - Roll out to production with `serial: 1` once staging verification passes.
- Documentation:
  - Add migration notes and alternatives guidance to `roles/proxmox_hypervisor/README.md` (done separately).
  - Record verification steps and results in Memory Bank after testing completes.

### Known Issues / Notes
- The repo refactor assumes `proxmox_distro` may be provided via inventory or extra-vars; document this in README and playbook wrapper if not present.
- Be conservative with network/firewall changes: use `serial: 1`, `--check --diff` first, and ensure OOB access is available for recovery.
- Firewall rules require Proxmox API credentials for some operations; configure `proxmox_api_token_*` or `proxmox_api_password` securely in vault.

---

*Update this file as progress is made and verification completes.*
