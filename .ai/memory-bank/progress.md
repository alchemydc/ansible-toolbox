# progress.md

## Project Progress

**Purpose:**  
Tracks what works, what's left to build, current status, known issues, and the evolution of project decisions.

---

### What Works
- The `zaino` Docker image builds successfully using the `community.docker.docker_image_build` module.
- The container starts and runs with the correct UID/GID mapping for the `zaino` user.

### What's Left to Build
- [List features or components that still need to be built.]

### Current Status
The container now builds and runs, but runtime permission and SSL errors persist. Setting `grpc_tls = false` in the config is not sufficient to disable TLS enforcement. The only way to run `zaino` without TLS is to build it with the `disable_tls_unencrypted_traffic_mode` feature, which is not present in the official Docker image. This complicates both local testing and production deployments with external SSL termination.
### Known Issues
- The `zaino` container experiences runtime permission errors, which were partially addressed by setting the correct user.
- The `zaino` container exits with SSL-related errors, even when `grpc_tls = false` is set in the config.
- Disabling TLS enforcement requires a custom build of `zaino` with the `disable_tls_unencrypted_traffic_mode` feature.
### Evolution of Project Decisions
- Investigated disabling TLS for `zaino` in dev/test environments.
- Attempted to set `grpc_tls = false` in `zindexer.toml`, but this did not disable TLS enforcement.
- Determined that the only way to disable TLS is to build `zaino` with the `disable_tls_unencrypted_traffic_mode` feature, requiring a custom Docker image.
- Decision: Document findings and revisit custom build if needed in the future.
---

*Update this file regularly to reflect project progress and status.*
