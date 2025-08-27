# progress.md

## Project Progress

**Purpose:**  
Tracks what works, what's left to build, current status, known issues, and the evolution of project decisions.

---

## Time Machine / Samba Troubleshooting Progress (2025-08-27)

### What Works
- Quota synchronization implemented: `timemachine_quota` set to 3T, `fruit:time machine max size` enabled, ZFS `refquota` set to 3T on Proxmox.
- Samba configured as standalone fileserver: `server role = standalone server` in smb.conf, smbd explicitly enabled and running.
- AD DC errors eliminated: samba-ad-dc stopped and masked, nmbd disabled, winbind management removed.
- Handler and notify logic only restart smbd.
- Documentation updated with ZFS quota instructions and service rationale.
- DFS disabled (host msdfs = no, msdfs root = no) resolves parse_dfs_path errors for TM restores.
- fruit:resource = xattr and fruit:locking = none allow Finder writes and TM backup after reboot on at least one Mac.
- Legacy and new Macs can mount and write to the share after reboot.

### What's Left to Build
- Test backup after reboot on remaining affected Mac.
- If ACL errors persist, disable NT ACL support and unify ownership/masks in the share.
- Monitor Samba logs for any new errors.
- Review quota usage and adjust if needed.
- Document ZFS aclmode/aclinherit recommendations if NT ACL support is needed.

### Current Status
- Role applies cleanly; smbd is enabled and running.
- AD DC errors are eliminated.
- Quota management is enforced: ZFS refquota and fruit:time machine max size both set to 3T.
- TM backups work after reboot on one Mac; other Macs pending test.
- Finder writes succeed; TM backups fail instantly if ACL errors persist.
- Server logs show fruit_fset_nt_acl failures on .tmp files inside sparsebundles.

### Known Issues
- fruit_fset_nt_acl failures block TM backups if NT ACL support is enabled.
- ZFS quota and Samba-advertised TM size must match to avoid “disk full” errors.
- ACL handling is critical for sparsebundle compatibility; disabling NT ACLs may be required.

### Evolution of Project Decisions
- Disabled DFS to resolve TM restore issues.
- Switched fruit:resource to xattr for ZFS compatibility.
- Added fruit:locking = none for TM reliability.
- Commented out fruit:time machine max size to avoid quota mismatch.
- Considering disabling NT ACL support and unifying ownership/masks for TM share.
- Planning to align ZFS refquota with desired TM size for long-term quota management.

---

## Previous Progress: zaino container troubleshooting

**Purpose:**  
Tracks what works, what's left to build, current status, known issues, and the evolution of project decisions.

---

### What Works
- The `zaino` Docker image builds successfully using the `community.docker.docker_image_build` module.
- The container starts and runs with the correct UID/GID mapping for the `zaino` user.

### What's Left to Build
- [List features or components that still need to be built.]

### Current Status
The container now builds and runs, but runtime permission and SSL errors persist. Both `zingodevops/zaino:v0.1.2-rc3` and `zingodevops/zaino:v0.1.2-rc3-no-tls` images have the same hash and both fail with TLS errors at startup. Setting `grpc_tls = false` in the config is not sufficient to disable TLS enforcement. The only way to run `zaino` without TLS is to build it with the `disable_tls_unencrypted_traffic_mode` feature, which is not present in the official Docker image. This complicates both local testing and production deployments with external SSL termination. An issue was raised with the Zaino team: https://github.com/zingolabs/zaino/issues/265

### Known Issues
- The `zaino` container experiences runtime permission errors, which were partially addressed by setting the correct user.
- The `zaino` container exits with SSL-related errors, even when `grpc_tls = false` is set in the config.
- Both the standard and "no-tls" Docker images fail with `ConfigError("TLS required when connecting to external addresses.")` and related warnings about missing TLS config.
- Disabling TLS enforcement requires a custom build of `zaino` with the `disable_tls_unencrypted_traffic_mode` feature.

### Evolution of Project Decisions
- Investigated disabling TLS for `zaino` in dev/test environments.
- Attempted to set `grpc_tls = false` in `zindexer.toml`, but this did not disable TLS enforcement.
- Tested both the standard and "no-tls" Docker images, found they are identical and both enforce TLS.
- Raised issue with Zaino team: https://github.com/zingolabs/zaino/issues/265
- Determined that the only way to disable TLS is to build `zaino` with the `disable_tls_unencrypted_traffic_mode` feature, requiring a custom Docker image.
- Decision: Document findings and revisit custom build if needed in the future.

---

*Update this file regularly to reflect project progress and status.*
