# activeContext.md

## Active Context

**Purpose:**  
Tracks current work focus, recent changes, next steps, active decisions, important patterns, and project insights.

---

### Current Focus
- Resolving runtime errors with the `zaino` container, specifically permissions and SSL issues.

### Recent Changes
- The `zaino` Docker image now builds successfully using the `community.docker.docker_image_build` module.
- The `zaino.service.j2` template has been updated to run the container with the correct user and group ID (10003).
- The container now starts, but runtime permission and SSL errors persist.

### Next Steps
- Investigate and resolve SSL errors in the `zaino` container.
- Explore options for running `zaino` without SSL for local/testing deployments, or document required SSL configuration for production.

### Active Decisions & Considerations
- The container must run as UID/GID 10003 to match the internal `zaino` user.
- SSL appears to be a hard requirement for `zaino`, complicating deployments where SSL is terminated elsewhere.

### Patterns & Preferences
- Use the correct UID/GID for Docker volume mounts to avoid permission errors.
- Prefer modules that support BuildKit and modern Docker features.

### Learnings & Insights
- The `zaino` `Dockerfile` uses modern Docker features that depend on the BuildKit engine.
- `zaino` requires SSL to run, which complicates both local testing and production deployments with external SSL termination.

---

*Update this file regularly to reflect the current state of the project.*
