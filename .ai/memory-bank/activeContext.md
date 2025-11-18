# activeContext.md

## Active Context

**Purpose:**  
Tracks current work focus, recent changes, next steps, active decisions, important patterns, and project insights.

---

## Time Machine / Samba Troubleshooting Context (2025-08-27)

### Current Focus
- Resolving Time Machine backup failures over SMB on ZFS after DFS and ACL changes.
- Ensuring compatibility for both new and legacy macOS clients backing up to the same share.

### Recent Changes
- Quota synchronization: `timemachine_quota` set to 3T in role defaults, `fruit:time machine max size` enabled in smb.conf, ZFS `refquota` set to 3T on Proxmox dataset.
- Samba configuration: `server role = standalone server` set in smb.conf; smbd explicitly enabled and started via systemd task; samba-ad-dc stopped and masked; nmbd disabled with service_facts guard; all winbind management removed.
- Handler logic: only restarts smbd; template task notifies restart smbd.
- Documentation: README updated with instructions for setting ZFS refquota on Proxmox and rationale for service configuration.
- Disabled DFS (host msdfs = no, msdfs root = no) to resolve parse_dfs_path errors.
- Enforced SMB3, disabled NetBIOS, set map to guest = Never.
- Updated fruit:resource to xattr for ZFS compatibility.
- Added fruit:locking = none for TM stability.
- Validated Finder write access and backup success after reboot on one Mac.

### Next Steps
- Test backup after reboot on remaining affected Mac.
- If ACL errors persist, consider disabling NT ACL support and unifying ownership/masks in the share.
- Plan long-term quota/space management: align ZFS refquota with desired TM size or re-enable fruit:time machine max size with safe value.
- Document ZFS aclmode/aclinherit recommendations if NT ACL support is needed.

### Active Decisions & Considerations
- Use fruit:resource = xattr for ZFS (xattr=sa) and legacy sparsebundle compatibility.
- Keep fruit:locking = none for TM reliability.
- Avoid setting fruit:time machine max size unless ZFS refquota matches.
- Consider nt acl support = no and inherit owner = yes if ACL errors block TM.

### Patterns & Preferences
- Prefer minimal, reversible smb.conf changes for troubleshooting.
- Document all changes and rationale in Memory Bank for future reference.

### Learnings & Insights
- DFS disables are required for TM restore/backup on modern macOS.
- ZFS quota and Samba-advertised TM size must match to avoid “disk full” errors.
- ACL handling is critical for sparsebundle compatibility; disabling NT ACLs may be required.

---

## Previous Context: zaino container troubleshooting

**Purpose:**  
Tracks current work focus, recent changes, next steps, active decisions, important patterns, and project insights.

---

### Current Focus
- Resolved runtime permission issues with the `zaino` container.
- Investigated persistent SSL/TLS errors when running `zaino` in a dev environment, even with `grpc_tls = false` set in the config.
- Tested both `zingodevops/zaino:v0.1.2-rc3` and `zingodevops/zaino:v0.1.2-rc3-no-tls` Docker images; both have the same hash and both fail with TLS errors at startup.
- Observed error: `ConfigError("TLS required when connecting to external addresses.")` and related warnings about missing TLS config.
- Raised issue with Zaino team: https://github.com/zingolabs/zaino/issues/265
- Determined that disabling TLS enforcement requires a custom build of `zaino` with the `disable_tls_unencrypted_traffic_mode` feature.

### Recent Changes
- The `zaino` Docker image now builds successfully using the `community.docker.docker_image_build` module.
- The `zaino` service template has been updated to run the container with the correct user and group ID (10003).
- The container now starts, but runtime permission and SSL errors persist.

### Next Steps
- Document findings regarding the TLS enforcement in `zaino` and the need for a custom build to disable it.
- Revisit custom Docker build with `disable_tls_unencrypted_traffic_mode` feature if running without TLS is required in the future.

### Active Decisions & Considerations
- The container must run as UID/GID 10003 to match the internal `zaino` user.
- The zaino repo is located at https://github.com/zingolabs/zaino/
- Setting `grpc_tls = false` in `zindexer.toml` is not sufficient to disable TLS errors in dev/test environments.
- Disabling TLS enforcement requires compiling zaino with the `disable_tls_unencrypted_traffic_mode` feature, which is not done in the official Docker image.

### Patterns & Preferences
- Use the correct UID/GID for Docker volume mounts to avoid permission errors.
- Prefer modules that support BuildKit and modern Docker features.

### Learnings & Insights
- The `zaino` `Dockerfile` uses modern Docker features that depend on the BuildKit engine.
- `zaino` requires SSL/TLS to run unless built with the `disable_tls_unencrypted_traffic_mode` feature.
- The official Docker image does not include this feature, so TLS enforcement cannot be disabled at runtime via config alone.
- This complicates both local testing and production deployments with external SSL termination.

---

## Proxmox Firewall Cluster Communication & Loopback Rules (2025-11-17)

### Issue Summary
After deploying firewall policy, multiple lockout incidents occurred (dev cluster became inaccessible after initial deployment, then again later). Investigation revealed two critical firewall rule gaps:

1. **Admin network rule constraint:** Original rule pos 1 specified both `iface: "wg0"` and `source: "+admin_network"`, creating a race condition during Wireguard tunnel establishment.
2. **Missing loopback rules:** No explicit rules for `iface: "lo"` traffic, blocking critical Proxmox service-to-service communication (corosync, pvedaemon, PVE proxy, etc.).

### Recent Changes (2025-11-17)
- **Removed interface constraint from admin_network rule (pos 1):** Changed to allow all admin_network traffic regardless of interface. Prevents race condition where traffic from admin network arrives before wg0 interface is fully initialized.
- **Added loopback INPUT rule (pos 0):** Explicit ACCEPT for `iface: "lo"` traffic to ensure Proxmox services can communicate locally (127.0.0.1/::1). Critical for corosync cluster state management, pvedaemon API calls, and local service discovery.
- **Confirmed OUTPUT policy:** User verified cluster has `policy_out: ACCEPT`, so explicit OUTPUT rules not needed.
- **Simplified wg0 handling:** Maintained generic "allow all on wg0" rule (pos 2) since all cluster communication flows over Wireguard VPN tunnel.

### Root Cause Analysis

**Why lockouts occurred:**
1. **Stateful connection tracking masked initial issues:** When firewall first deployed, existing cluster connections persisted via stateful tracking despite incomplete rules.
2. **Connection timeout trigger:** Hours later, when a corosync or cluster connection naturally reset/timed out/restarted, node attempted to re-establish.
3. **New connection blocked:** New connection attempt either:
   - Couldn't match admin_network rule if traffic arrived before wg0 was ready (timing race)
   - Couldn't match any explicit cluster port rules on wg0 if those ports weren't enumerated
   - Hit default deny if loopback traffic was blocked (blocking local service communication)
4. **Cluster partition:** When cluster services couldn't communicate locally (loopback) or inter-node (wg0), cluster node appeared offline.

### Active Decisions & Considerations
- **Loopback safety:** Always allow all loopback traffic; it's the most trusted interface and essential for system stability. Position 0 ensures it's checked before any denies.
- **Admin network without interface constraint:** Trust model assumes admin_network (10.10.68.0/24) is protected; no need to bind allow rule to specific interface.
- **Wireguard trust model:** wg0 is a security boundary; all traffic on wg0 is allowed since it's encrypted and authenticated.
- **OUTPUT policy:** With OUTPUT=ACCEPT, outbound traffic is implicitly allowed; only INPUT rules need explicit specification.

### Patterns & Preferences
- Firewall rules must account for temporal state (e.g., interface not yet fully up) and connection lifecycle (new vs established).
- Loopback rules are always necessary and should be the first rule evaluated.
- Trust boundaries simplify rules: classify interfaces/networks by trust level and apply bulk rules rather than per-port enumerations.
- Stateful tracking can mask incomplete rule sets during initial deployment; issues emerge hours/days later when connections reset.

### Learnings & Insights
- **Interface race conditions:** Constraints combining `iface` + `source` can fail during tunnel establishment if interface state and packet arrival timing are misaligned. Better to specify one constraint per rule and rely on rule ordering.
- **Loopback criticality:** Without explicit loopback rules, cluster services fail to communicate locally, causing node isolation and cluster partition even when inter-node communication might be working.
- **Temporal dynamics in firewalls:** Firewall rules must handle the full connection lifecycle (new, established, teardown), not just protocol/port. Timing-dependent failures are common in complex systems.
- **Testing gaps:** Applying firewall rules and waiting hours before testing is poor coverage. Always test immediately and also stress test after hours to catch stateful tracking issues.

### Next Steps
- Deploy updated firewall.yml to dev cluster and test for 24-48 hours.
- Verify no lockout incidents after deployment of loopback rule.
- Monitor Proxmox cluster logs for any corosync or service communication issues.
- Run playbook multiple times (idempotency check) to ensure rules don't duplicate.
- If stable, deploy to production cluster with serial: 1 and OOB console access available.
- Document loopback rules requirement in Proxmox firewall best practices in .clinerules.

---

## Proxmox Hypervisor Modernization (2025-11-14)

### Current Focus
- Modernized Proxmox firewall and Wireguard configuration for scalability and maintainability.
- Migrated from legacy iptables to Proxmox nftables with centralized management.
- Refactored Wireguard from 7+ per-host templates to single data-driven configuration.
- Improved service restart safety and swap configuration idempotency.
- **Latest:** Fixed Proxmox firewall cluster communication and loopback rule gaps (2025-11-17).

### Recent Changes
**Firewalling (Final fixes):**
- Fixed module data structure: IP sets now use `cidrs: [{cidr: "..."}]` format (dict, not string).
- Split single firewall task into 3 separate calls (IP sets, aliases, rules) to comply with module mutual exclusivity constraints.
- Added `update: true` parameter to all firewall tasks for idempotency.
- Implemented firewall enable/disable wrapper to prevent rule duplication:
  - Disable firewall → delete all old rules (loop pos 1-100) → apply new rules → re-enable firewall.
  - Prevents lockout (user connects via admin network + wireguard).
  - Fixes issue where duplicate default deny rules were accumulating each playbook run.
- Fixed firewall enable conditional: use `.get('enable', 0)` to handle missing API response keys (fresh clusters return only `{"digest":"..."}`).
- Tasks now robust against duplicate IP set addresses and rule position conflicts.

**Firewalling (Earlier work):**
- Created `group_vars/proxmox/firewall.yml` with centralized IP sets and filtering rules.
- Implemented `roles/proxmox_hypervisor/templates/pve-nat-rules.j2` for dynamic DNAT/SNAT generation.
- Replaced `configure_firewall.yml` tasks to use `community.proxmox.proxmox_firewall` module.
- Removed iptables/ip6tables template files and rsyslog/logrotate blocks (firewall logs now via `journalctl -fu proxmox-firewall`).
- Added `Reload proxmox-firewall` handler for safe service restarts.

### Active Decisions & Considerations
- **Firewall:** Use Proxmox API (via `community.proxmox` module) for cluster-wide rule management; NAT rules deployed as nftables files.
- **Wireguard:** Dictionary-based vault for key management; single dynamic template for all hosts; naming-agnostic endpoint resolution.
- **Handler Pattern:** Simple handlers in main.yml; task-level block/rescue for service restart safety (Ansible doesn't support block/rescue in handlers).
- **Rollback:** Config backup + `wait_for_connection` in rescue block ensures host stays reachable even if config is corrupted.
- **Swap:** Detect by partition type, not name; calculate next partition number dynamically; multi-disk support with loop scoping.

### Patterns & Preferences
- **Data-driven:** All peer configs in YAML, templates generate from single source.
- **Vault security:** Private keys encrypted; use `--ask-vault-pass` or `ANSIBLE_VAULT_PASSWORD_FILE`.
- **Idempotency:** Check for existing state before making changes; use `changed_when: false` for read-only tasks.
- **Safety:** Network/system changes use backups + conditional restarts; always test with `--check --diff`.
- **Testing:** Dry-run before deploying; verify service state after changes.

### Learnings & Insights
- Per-host templates scale poorly; dictionary-driven configs simplify management by 7x.
- Ansible handlers cannot use block/rescue; move complex restart logic to task-level instead.
- Simple handlers are required; `block` is not valid in handler definitions.
- Idempotent tasks with conditional execution prevent unnecessary system changes and are easier to debug.
- Multi-disk systems need per-iteration scoping; `set_fact` resets facts each loop iteration, which is the correct behavior.
- Proxmox nftables backend logs to `journald` (not syslog), simplifying troubleshooting.
- Alternatives adjusted programmatically in `roles/stacks_node/tasks/configure_firewall.yml` to prefer *-nft wrapper binaries, preventing legacy iptables kernel modules from being loaded by default.
- **Proxmox firewall module quirks:**
  - `update: true` is default but doesn't prevent duplicates; module matches rules by content, not position.
  - Parameters `ip_sets`, `aliases`, `rules` are mutually exclusive in a single task call.
  - Firewall must be disabled during rule cleanup/replacement to prevent lockouts (disable → delete → apply → enable).
  - API returns `{"digest":"..."}` only when no options exist; use `.get('enable', 0)` for safe key access.
  - IP set format requires `cidrs: [{cidr: "..."}]` (dict list), not string list.
- Fresh Proxmox clusters have firewall disabled by default; enable task must handle missing `enable` key in API response.

### Next Steps
- Complete firewall rule deployment and verify no rule duplication on next playbook run.
- Test idempotency: run playbook 2-3 times, confirm firewall remains enabled and rules don't duplicate.
- User fills vault with remaining private keys (zd4-zd7, dc-m4mba) from encrypted templates or key backup.
- Test Wireguard config generation and handler rollback on staging host.
- Verify swap creation is idempotent (run twice, only first should create swap).
- Monitor Wireguard restarts and handler execution in production.

---

## Recent work: Proxmox 9 (Debian 13 / trixie) repo & inventory updates (2025-11-13)

### Summary of actions
- Implemented safer Proxmox community repo handling in `roles/base_server/tasks/configure_proxmox_repos.yml`:
  - Remove enterprise repo artifacts ( both `.list` and `.sources` ) before enabling community repo.
  - Download Proxmox signing key from `https://enterprise.proxmox.com/debian/proxmox-release-{{ proxmox_distro }}.gpg` into `/usr/share/keyrings/proxmox-archive-keyring.gpg`.
  - Create `pve-community.sources` (new `.sources` syntax) on hosts with `proxmox_distro` >= `trixie`; use legacy `.list` for older distros.
  - Use `Signed-By` / keyring usage avoids global apt-key additions.
- Fixed inventory warnings:
  - Replaced invalid inventory variable keys (e.g. `sdn:mtu` → `sdn_mtu`) where present.
  - Resolved group/host name collision by renaming host entry or group where appropriate.
  - Normalized group names to avoid characters that Ansible warns about (hyphens replaced with underscores where applied).
- Decision: centralize Proxmox repo management in `base_server` and make `proxmox_hypervisor` repo tasks opt-in via `manage_proxmox_repos` variable.
- Confirmed `base_server` role applies cleanly on Proxmox 9 host (zd1) when repo/key changes are present.

