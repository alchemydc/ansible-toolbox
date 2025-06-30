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
### Development Setup
- Ansible roles manage service and configuration templates.
- Zaino is run as a Docker container, started via a systemd service template.
- The Zaino configuration is templated at `roles/zcash_node/templates/zindexer.toml.j2` and mounted into the container.
- For local development or testing without TLS, a custom Docker image must be built with the `disable_tls_unencrypted_traffic_mode` feature enabled.
### Technical Constraints
- Official Zaino Docker images enforce TLS unless built with the `disable_tls_unencrypted_traffic_mode` feature.
- Setting `grpc_tls = false` in the config is not sufficient to disable TLS enforcement.
- Custom Docker build is required to disable TLS for non-private addresses.
### Dependencies
- Zaino Docker image (official or custom)
- Ansible roles and templates
- Rust toolchain (for custom Zaino builds)
### Tool Usage Patterns
- Use Ansible to manage Docker containers and configuration files.
- Zaino configuration is managed via Jinja2 template and mounted into the container.
- If running without TLS is required, fork the Zaino repo and build the Docker image with the `disable_tls_unencrypted_traffic_mode` feature.
---

*Update this file as the technical context evolves.*
