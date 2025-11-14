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

- `proxmox_hypervisor` role now includes standalone repo management and safer networking:
  - Added `manage_proxmox_repos: true` in `roles/proxmox_hypervisor/defaults/main.yml` to enable repo management by default when the role runs standalone.
  - `roles/proxmox_hypervisor/tasks/configure_proxmox_repos.yml` refactored to mirror `base_server` logic:
    - Defines `proxmox_distro_order` and supports trixie+ `.sources` format.
    - Removes enterprise repo artifacts (both `.list` and `.sources`) and any `enterprise.proxmox.com` lines from `/etc/apt/sources.list`.
    - Downloads the Proxmox archive GPG key into `/usr/share/keyrings/proxmox-archive-keyring.gpg` and uses `Signed-By` where applicable.
    - Task execution is guarded by `manage_proxmox_repos` and permits standalone operation or opt-out when centralized.
  - Implemented an ifupdown-only safe networking handler in `roles/proxmox_hypervisor/handlers/main.yml`:
    - Handler restarts `networking` (if present), pauses, waits for SSH via `wait_for_connection`, and on failure restores the template backup using `net_tpl.backup_path`.
  - Updated `roles/proxmox_hypervisor/tasks/main.yml` to gather service_facts, register the networking template as `net_tpl`, and notify the new handler.

- Inventory and linting improvements:
  - Invalid inventory variable keys were corrected (e.g. `sdn:mtu` → `sdn_mtu`).
  - Group/host name collisions and problematic characters addressed where applied.

### What's Left to Build / Verify
- Run a full dry-run and staged apply on a development/staging Proxmox node:
  - Validate pvesm, pve-cluster, pveproxy, and other PVE service operations.
  - Verify ZFS dataset and pvesm add operations succeed as expected.
- Verify `proxmox_hypervisor` repo task behavior and idempotence across:
  - Older distros (bookworm) and newer distros (trixie+)
  - Hosts with `ansible_virtualization_role` defined as `host` and hosts where it is undefined
- Recreate or recover `roles/base_server/files/etc_hosts.vault` if required by deployments
- Make SDN-related helper package installation configurable (`libpve-network-perl`, `frr-pythontools`) to avoid unnecessary installs or failures on newer Proxmox installs
- Update `systemPatterns.md` and `activeContext.md` with the new standalone proxmox_hypervisor decisions and networking handler pattern
- Expand automated inventory validation tests and add staged verification playbooks

### Current Status
- Repo/key workflow implemented and tested in dry-run context for `base_server`.
- `proxmox_hypervisor` updated to support standalone repo management; defaults and refactor completed.
- Networking handler moved into role handlers and the networking template task now registers its backup for rollback.
- Next actions require a staging run (dry-run with `--check --diff`) and verification across distro variants.

### Known Issues / Notes
- The repo refactor assumes `proxmox_distro` will be provided via inventory or extra-vars; if not, set it in group_vars/host_vars or via `-e`.
- .gitignore contains an entry for `etc_hosts*.vault` — if you intend to commit an encrypted hosts file, update `.gitignore` accordingly or manage the file via an external secrets store.
- Be conservative with network changes: use `serial: 1`, `--check --diff` first, and test rollback behavior on staging.

---

*Update this file as progress is made and verification completes.*
