# Monitor Client Role

This role deploys monitoring agents to client hosts. It supports a **Hybrid Architecture**, allowing you to choose between the **Legacy** stack (Node Exporter + Promtail) or the Unified **Grafana Alloy** agent on a per-host basis.

## Architecture Modes

Controlled by the `monitor_agent_type` variable.

### 1. Legacy Mode (`legacy`) - 
- **Components**: Installs `node_exporter` (SystemD) and `promtail` (SystemD) binaries.
- **Behavior**:
  - `node_exporter` listens on port `9100` (Scraping).
  - `promtail` pushes logs to `loki_uri`.
- **Cleanup**: If switched **to** legacy from alloy, the `alloy` service will be stopped and disabled to prevent metric duplication.

### 2. Alloy Mode (`alloy`) *Default*
- **Components**: Installs `alloy` (SystemD) from the official Grafana APT repository.
- **Behavior**:
  - `prometheus.exporter.unix`: Collects system metrics.
  - `prometheus.remote_write`: Pushes metrics to `prometheus_write_uri`.
  - `loki.source.journal`: Collects system logs.
  - `loki.write`: Pushes logs to `loki_write_uri`.
- **Cleanup**: If switched **to** alloy from legacy, the `node-exporter` and `promtail` services will be stopped and disabled.

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `monitor_agent_type` | `"alloy"` | Set to `"legacy"` to switch agent modes. |
| `alloy_version` | `"latest"` | Version of the Alloy package to install. |
| `prometheus_write_uri` | `http://monitor:9090/api/v1/write` | Target for Alloy metric pushes (Remote Write). |
| `loki_uri` | `http://monitor:3100/loki/api/v1/push` | Target for Promtail/Alloy log pushes. |

## Usage

### Default (Legacy)
```yaml
# host_vars/myhost.yml
monitor_agent_type: "legacy"
```

### Switch to Alloy
```yaml
# host_vars/myhost.yml
monitor_agent_type: "alloy"
```

> **Note**: When switching to Alloy, the host will stop listening on port `9100`. Ensure your Prometheus server is configured to accept Remote Write (Push) metrics to allow data continuity.
