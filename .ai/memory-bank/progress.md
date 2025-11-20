# progress.md

## Project Progress

**Purpose:**  
Tracks what works, what's left to build, current status, known issues, and the evolution of project decisions.

---

## Recent Progress (2025-11-19)

### What Works
- `base_server` role now handles Proxmox repository/key management robustly on Proxmox 9 (trixie).
- `proxmox_hypervisor` role includes safer repo handling and networking fixes.
- Native `nftables` firewall deployment completed and validated:
  - Centralized filtering and IP sets in `group_vars/proxmox/firewall.yml`.
  - NAT/DNAT/SNAT rendered via `roles/proxmox_hypervisor/templates/nftables.conf.j2`.
  - Deployed configs validated with `nft -c -f` and `nft list ruleset`. Proxmox firewall services are masked/disabled where nftables is used.
- `tmux` deployed across managed hosts via `roles/base_server` for session multiplexing and recovery.
- IPv6 disabled for Proxmox 9 guests (trixie) where required via sysctl/cloud-init templates (`net.ipv6.conf.*.disable_ipv6=1`).

- Decision: abandoned the `proxmox-firewall` abstraction for our deployments due to brittleness under Ansible and lack of reliable DNAT support. NAT/DNAT responsibilities are handled by native `nftables` templates; Proxmox API may be used for cluster-wide filtering only where stable.

### Current Status
- Firewall: Migrated from iptables to nftables; central rules and NAT templates render correctly. Need to confirm idempotency across repeated runs.
- IPv6: Disabled for affected guests; monitor networking for regressions.
- tmux: Installed and configured; document usage and any host-specific tweaks.

### What's Left to Build / Verify
- Run playbook 2-3x on staging nodes to confirm idempotency for nftables, IPv6-disable, and tmux tasks.
- Verify DNAT rules appear in `/etc/nftables.conf` and are active with `nft list ruleset`.
- Monitor staging for 24-48 hours to ensure no service regressions or lockouts.
- Update `roles/proxmox_hypervisor/README.md` and Memory Bank with the proxmox-firewall decision and NAT handling approach.
- Record verification results and any follow-up fixes back into Memory Bank.

### Known Issues / Notes
- Be conservative with network/firewall changes: use `serial: 1`, `--check --diff` first, and ensure OOB access is available for recovery.
- Firewall tasks require Proxmox API credentials for some operations; configure `proxmox_api_token_*` or `proxmox_api_password` securely in vault.

---

