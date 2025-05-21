# monitor server
this role creates a prometheus, loki and promtail stack managed by docker compose.

log data retention is configurable via the `loki_retention_period` variable in [defaults/main.yml](defaults/main.yml)
prometheus data retention is configurable via the `prometheus_retention_period` variable in [defaults/main.yml](defaults/main.yml)

note that loki is presently pinned to v3.4 due to a log spam bug in v3.5.
