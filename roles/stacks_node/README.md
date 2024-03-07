# Stacks Node
This role will create a signer for a [Stacks.co](https://www.stacks.co/) node.

This is a work in progress.

## Helpful aliases
These aliases are installed into the stacks user's .profile:
* `alias start_signer='/home/{{ svc_user }}/stacks-blockchain/target/debug/stacks-signer run --config signer.toml'`
* `alias stacks='npx stacks`

## Key management
To create a new (hot) keypair: `stacks_cli make_keychain`
Do not use hot keys in production.

## Documentation
* https://docs.stacks.co/nakamoto-upgrade/stacking-flow
* https://docs.stacks.co/nakamoto-upgrade/running-a-signer


## Sample output
```
stacks@stacks-dev:~$ start_signer
Signer spawned successfully. Waiting for messages to process...
INFO [1709826195.886241] [stacks-signer/src/runloop.rs:278] [signer_runloop] Running one pass for signer ID# 0. Current state: Uninitialized
```

