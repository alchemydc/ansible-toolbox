# Lightwalletd cli param reference

Lightwalletd is a backend service that provides a bandwidth-efficient interface to the Zcash blockchain

```
Usage:
  lightwalletd [flags]
  lightwalletd [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  help        Help about any command
  version     Display lightwalletd version

Flags:
      --config string            config file (default is current directory, ightwalletd.yaml)
      --darkside-timeout int     override 30 minute default darkside timeout default 30)
      --darkside-very-insecure   run with GRPC-controllable mock zcashd for ntegration testing (shuts down after 30 minutes)
      --data-dir string          data directory (such as db) (default "/var/ib/lightwalletd")
      --gen-cert-very-insecure   run with self-signed TLS certificate, only or debugging, DO NOT use in production
      --grpc-bind-addr string    the address to listen for grpc on (default 127.0.0.1:9067")
      --grpc-logging-insecure    enable grpc logging to stderr
  -h, --help                     help for lightwalletd
      --http-bind-addr string    the address to listen for http on (default 127.0.0.1:9068")
      --log-file string          log file to write to (default "./server.log")
      --log-level int            log level (logrus 1-7) (default 4)
      --no-tls-very-insecure     run without the required TLS certificate, nly for debugging, DO NOT use in production
      --ping-very-insecure       allow Ping GRPC for testing
      --redownload               re-fetch all blocks from zcashd; reinitialize ocal cache files
      --rpchost string           RPC host
      --rpcpassword string       RPC password
      --rpcport string           RPC host port
      --rpcuser string           RPC user name
      --sync-from-height int     re-fetch blocks from zcashd start at this eight (default -1)
      --tls-cert string          the path to a TLS certificate (default "./ert.pem")
      --tls-key string           the path to a TLS key file (default "./cert.ey")
      --zcash-conf-path string   conf file to pull RPC creds from (default "./cash.conf")
```

## Testing
test proper operation with
 * `grpcurl hostname:443 list`
 * `grpcurl -plaintext hostname:9067 list` if no SSL frontend

## SSL Termination on reverse proxy layer
 traefik config for grpc backend as follows:
 key is to use `h2c` scheme for backend

```
 zcash-dev-lwd:
      loadBalancer:
        servers:
          - url: "h2c://1.2.3.4:9067"  # lightwalletd grpc service
```
