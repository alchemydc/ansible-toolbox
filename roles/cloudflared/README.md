# Ansible Role: cloudflared

Installs Cloudflare's cloudflared via APT using keyrings and apt_repository.

## Requirements

- Debian (bullseye, bookworm) or Ubuntu (focal, jammy, noble)
- Ansible 2.12+

## Role Variables

See `defaults/main.yml` for all configurable variables.

## Example Playbook

```yaml
- hosts: cloudflared_hosts
  become: true
  roles:
    - cloudflared
```

## Tasks

- Ensures keyrings directory exists
- Downloads Cloudflare GPG key
- Adds Cloudflare APT repository
- Installs cloudflared package

## License

MIT

## Author

alchemydc
