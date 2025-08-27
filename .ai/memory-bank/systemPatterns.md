# systemPatterns.md

## System Patterns

**Purpose:**  
Documents system architecture, key technical decisions, design patterns, component relationships, and critical implementation paths.

---

### System Architecture
[Describe the overall system architecture.]

### Key Technical Decisions
- Zaino is deployed as a Docker container managed by Ansible.
- TLS enforcement in Zaino cannot be disabled at runtime; it requires a custom build with the `disable_tls_unencrypted_traffic_mode` feature.
- The official Docker image does not include this feature, so deployments must use TLS unless a custom image is built.
### Design Patterns
- Fileserver-only Samba pattern: Only smbd is enabled and running; AD DC service is stopped and masked; NetBIOS (nmbd) is disabled with service_facts guard; winbind management is removed.
- Conditional service management: All service tasks use service_facts to avoid errors for missing units.
- Handler and notify logic only restart smbd.
- Quota synchronization pattern: ZFS refquota and fruit:time machine max size are set from a single variable (`timemachine_quota`) to ensure consistency.
- Configuration is managed via Jinja2 templates and mounted into containers.
- Service deployment is handled by systemd unit templates.
- Security and network features (like TLS) are enforced at the application build level, not just via configuration.  This is not desirable and should be fixed upstream.
### Component Relationships
- [Describe relationships between major components.]

### Critical Implementation Paths
- Quota enforcement: Set `timemachine_quota` in role defaults, enable `fruit:time machine max size` in smb.conf, and set ZFS `refquota` on Proxmox to match.
- Ensure smbd is enabled and running via explicit systemd task.
- Mask and stop samba-ad-dc; disable nmbd with service_facts guard.
- To disable TLS enforcement in Zaino, fork the repo and build the Docker image with the `disable_tls_unencrypted_traffic_mode` feature enabled.
- The configuration template for Zaino is located at `roles/zcash_node/templates/zindexer.toml.j2`.
---

*Update this file as system patterns and architecture evolve.*
