# Monitor Server Role

This role deploys a monitoring stack consisting of **Prometheus**, **Loki**, and **Grafana**, managed via Docker Compose.

## Architecture

The monitoring stack supports a **Hybrid** architecture to facilitate the migration from legacy Node Exporter clients to next-generation Grafana Alloy clients.

### 1. Prometheus (Metrics)
- **Pull Mode (Legacy)**: Continues to scrape legacy targets defined in `monitored_hosts` on port `9100` (Node Exporter).
- **Push Mode (Alloy)**: Accepts metrics pushed from Grafana Alloy clients via the **Remote Write** receiver API.
  - **Endpoint**: `http://<server-ip>:9090/api/v1/write`
  - **Note**: The Remote Write receiver is currently enabled **without authentication**.

### 2. Loki (Logs)
- Receives logs pushed by clients (Promtail or Alloy) on port `3100`.
- **Note**: `auth_enabled` is set to `false`, meaning multi-tenancy is disabled and no authentication is required for ingestion.

### 3. Grafana (Visualization)
- Connects to local Prometheus and Loki datasources.
- Provides visualization for both legacy and Alloy-collected metrics.

## Configuration Updates (Alloy Support)

To support Grafana Alloy, the following changes were made:
- **Remote Write**: Enabled `--web.enable-remote-write-receiver` on Prometheus.
- **External Labels**: Added `cluster` and `environment` external labels to Prometheus config to identify this server's metrics when fed to upstream systems.
- **Internal Monitoring**: Added a scrape job `alloy-internal` to monitor Alloy's own metrics on port `12345`.

## Data Retention
- **Loki**: Configurable via `loki_retention_period` in `defaults/main.yml`.
- **Prometheus**: Configurable via `prometheus_retention_period` in `defaults/main.yml`.

> **Note**: Loki is presently pinned to v3.4 to avoid a known log spam bug in v3.5.

## Roadmap: Authentication & Security

The current "Phase 1" implementation prioritizes functionality and ease of migration within a trusted private network.

**Upcoming Security Improvements:**
1.  **Authentication**:
    - Implement Basic Authentication for the Prometheus Remote Write endpoint.
    - Options include native Prometheus `web-config` (requires bcrypt) or an Nginx sidecar.
2.  **TLS**:
    - Enable TLS termination to encrypt metric traffic in transit.
    - Likely to be implemented via Nginx sidecar or ingress controller.

> [!WARNING]
> **Security Notice**: Port `9090` (Prometheus) and `3100` (Loki) are currently exposed without authentication. Ensure this server is protected by a firewall (UFW/Security Groups) and is only accessible from trusted client IPs.
