# Postfix Smarthost Role

Configures Postfix to relay outbound mail through an authenticated SMTP smarthost.

## What It Does

- Installs `postfix` and `libsasl2-modules`
- Deploys `/etc/postfix/main.cf`
- Deploys `/etc/postfix/sasl_passwd`
- Deploys `/etc/postfix/generic`
- Rebuilds `sasl_passwd.db`

## Required Variables

- `smarthost_domain`
- `smtp_relay_host`
- `smtp_relay_port`
- `smtp_relay_interfaces`
- `smtp_relay_username`
- `smtp_relay_password`

## Proton Mail Behavior

When used with Proton Mail SMTP, the role rewrites every outbound sender address to `smtp_relay_username` via `smtp_generic_maps`. This keeps the envelope and header sender aligned with the authenticated SMTP identity required by Proton.

## Example

```yaml
- hosts: smarthost
  become: true
  roles:
    - postfix_smarthost
```

Example tagged run:

```bash
ansible-playbook main.yml --tags postfix_smarthost -e "target=smarthost"
```
