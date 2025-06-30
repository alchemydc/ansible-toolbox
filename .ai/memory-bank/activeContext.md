# activeContext.md

## Active Context

**Purpose:**  
Tracks current work focus, recent changes, next steps, active decisions, important patterns, and project insights.

---

### Current Focus
- Resolved runtime permission issues with the `zaino` container.
- Investigated persistent SSL/TLS errors when running `zaino` in a dev environment, even with `grpc_tls = false` set in the config.
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
