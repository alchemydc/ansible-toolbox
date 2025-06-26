# activeContext.md

## Active Context

**Purpose:**  
Tracks current work focus, recent changes, next steps, active decisions, important patterns, and project insights.

---

### Current Focus
- Troubleshooting the Docker build for the `zaino` indexer.

### Recent Changes
- The `zaino` Docker build is failing with an error indicating that BuildKit is required.

### Next Steps
- Modify the `docker_image` task in `roles/zcash_node/tasks/install_zaino.yml` to enable BuildKit. This can be done by adding an `environment` variable to the task: `DOCKER_BUILDKIT=1`.

### Active Decisions & Considerations
- [Document key decisions and considerations.]

### Patterns & Preferences
- [Note important patterns, conventions, or preferences.]

### Learnings & Insights
- The `zaino` `Dockerfile` uses modern Docker features that depend on the BuildKit engine.

---

*Update this file regularly to reflect the current state of the project.*
