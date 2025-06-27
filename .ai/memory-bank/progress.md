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
The container now builds and runs, but runtime permission and SSL errors persist. SSL appears to be a hard requirement for `zaino`, complicating both local testing and production deployments with external SSL termination.

### Known Issues
- The `zaino` container experiences runtime permission errors, which were partially addressed by setting the correct user.
- The `zaino` container exits with SSL-related errors, as it seems to require SSL even for local/testing deployments.

### Evolution of Project Decisions
- [Document how and why major decisions have changed over time.]

---

*Update this file regularly to reflect project progress and status.*
