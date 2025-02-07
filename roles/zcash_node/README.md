# Zcash Node
This role will create a Zcash [Zebra](https://github.com/ZcashFoundation/zebra) node.

Presently this role is sufficient to build Zebra from source, (or Docker) run it from systemd, and sync mainnet to tip.

[Lightwalletd](https://zebra.zfnd.org/user/lightwalletd.html) support has been added so that you can connect Zcash light clients such as [Zashi](https://electriccoin.co/zashi/) to your own infrastructure if desired.

This is a work in progress.

## Documentation
* https://zebra.zfnd.org/index.html
* https://zebra.zfnd.org/user/lightwalletd.html


## Todo
- [x] Docker support for Zebra
- [x] Docker support for [Lightwalletd](https://github.com/zcash/lightwalletd)
- [ ] Monitoring and alerting (work in progress). Working with ZF to get prometheus built into 'latest' Zebra docker image

Other components of the Zcash architecture may be added in the future, such as [Zaino](https://github.com/zingolabs/zaino/).


