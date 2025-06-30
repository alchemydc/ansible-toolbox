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
- Configuration is managed via Jinja2 templates and mounted into containers.
- Service deployment is handled by systemd unit templates.
- Security and network features (like TLS) are enforced at the application build level, not just via configuration.
### Component Relationships
- [Describe relationships between major components.]

### Critical Implementation Paths
- To disable TLS enforcement in Zaino, fork the repo and build the Docker image with the `disable_tls_unencrypted_traffic_mode` feature enabled.
- The configuration template for Zaino is located at `roles/zcash_node/templates/zindexer.toml.j2`.
---

*Update this file as system patterns and architecture evolve.*
