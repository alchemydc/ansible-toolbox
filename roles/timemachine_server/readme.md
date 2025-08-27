# Time Machine Server role
This role will configure an SMB server to serve as a target for Apple Time Machine backups. Previously 
such targets had to be served via AFP, but Apple added support for using SMB (Server Message Block) as a storage protocol for Time Machine backups starting with macOS Catalina (macOS 10.15) in 2019. Prior to macOS Catalina, Time Machine backups were primarily stored using the AFP (Apple Filing Protocol) or locally connected drives.

Tested using a Debian 12 LXC as the target and a M1 Macbook Air as the Time Machine client.

## ZFS specific configuration for underlying filesystem
If you are using ZFS as the underlying filesystem for the target, setting these options will boost performance:
*  Extended attributes are enabled by default in ZFS (xattr=on). The default storage is directory based, which is compatible with very old (pre-OpenZFS) implementations. The last open source version of OpenSolaris (Nevada b137) as well as all OpenZFS versions as far as I am aware supports storing extended attributes as system attributes, which greatly increase their performance due to fewer disk accesses. To switch to system attributes:
` sudo zfs set xattr=sa $zfs_filesystem`
* ZFS compression doesn't help with Time Machine backups (compressration = 1.00x) , so it is recommended to disable it:
`sudo zfs set compression=off $zfs_filesystem`
* Finally, it is recommended to set the recordsize to 1M since bands appear to be 256M each, so 1M recordsize should be a good match
`sudo zfs set recordsize=1M $zfs_filesystem`
* Disable atime to reduce disk writes
`sudo zfs set atime=off $zfs_filesystem`
* but enable relatime to keep track of the last access time of files
`sudo zfs set relatime=on $zfs_filesystem`

### Setting ZFS Quota for Time Machine on Proxmox

To prevent Time Machine backups from exceeding available space, set a ZFS refquota on the dataset used for backups. This quota should match the value configured in the Ansible role (`timemachine_quota`, default: 3T).

**Example command:**
```
sudo zfs set refquota=3T <pool>/<dataset>
```
Replace `<pool>/<dataset>` with your actual ZFS pool and dataset name.

**Important:**  
Ensure the `refquota` value matches the `fruit:time machine max size` in your Samba configuration to avoid backup failures or quota mismatch errors.

## Example script to do these changes
```
#!/bin/bash
set -ex

zfs_filesystem="pool/dataset/subvol-123-disk-0"

sudo zfs set xattr=sa "$zfs_filesystem"
sudo zfs set compression=off "$zfs_filesystem"
sudo zfs set recordsize=1M "$zfs_filesystem"
sudo zfs set atime=off "$zfs_filesystem"
sudo zfs set relatime=on "$zfs_filesystem"
sudo zfs set refquota=3T "$zfs_filesystem"
```

## Samba Service Configuration and Rationale

This role is designed to run Samba strictly as a standalone SMB fileserver for Time Machine backups. The Active Directory Domain Controller (AD DC) service (`samba-ad-dc`) is not required and is explicitly disabled and masked. NetBIOS (`nmbd`) and Winbind (`winbind`) services are also disabled unless AD integration is needed.

**Key points:**
- Only the `smbd` service is enabled and running.
- `samba-ad-dc` is stopped and masked to prevent unnecessary errors and resource usage.
- `nmbd` and `winbind` are disabled for security and simplicity.
- The `server role = standalone server` parameter is set in `smb.conf` to enforce fileserver-only operation.

This configuration avoids AD DC-related errors and ensures the server operates as a secure, minimal SMB target for macOS Time Machine.
