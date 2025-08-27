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
- The `zaino.service.j2` template has been updated to run the container with the correct user and group ID (10003).
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

*Update this file regularly to reflect the current state of the project.*
