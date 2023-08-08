# Celo Validator role
This role will build the Celo fork of Geth from source, and configure a Celo full node with a validator signer.  Note that this role does NOT implmement a sentry architecture using proxies in front of the validators at this time.

## Quickstart
1. Copy the example variable definition

    `cp vars/main.yml.example vars/main.yml`

 2. Edit [vars/main.yml](vars/main.yml.example) to taste.

    Note that the role needs private keys (for the validator signers) and passwords (used to decrypt the private keys on the filesystem). These are best stored in [ansible-vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html).  

3. Edit your `inventory.yml` as appropriate to add a host entry for the celo_validator

4. Run the playbook

    `ansible-playbook ../main.yml --tags "celo_validator" -e "target=celo_validator"`

    This will install the dependencies, clone the repo, build celo's geth fork from source, and install it as a systemd unit.

5. Sync the chain

    By default, geth will be started from systemd, and will begin syncing. You can see progress as follows:
    ```
    ssh celo_validator
    sudo su - celo
    geth attach
    eth.syncing
    eth.blockNumber
    ```

    Note that on baklava, you'll need to invoke geth as follows:
    `geth attach --datadir .celo/baklava/`

    Note also that DNS configuration is out of scope for this readme.

6. Restore the chain from snapshot

    Syncing the chain from genesis takes a long time. It's possible to instead restore from a snapshot using the helper script in `/home/celo/restore_from_snapshot.sh`.  Note that this approach sacrifices security for performance, as you become reliant on the snapshot provider to provide you with honest historical chain data.

7. Generate a proof of possession

    Celo's [key management architecture](https://docs.celo.org/validator/key-management/summary) is pretty sophisticated, and you're able to rotate validator signers every epoch, if you like. When bringing a new signer online, it's necessary to prove possession of the signer, and then authorize it with the appropriate key.

    A helper script exists on the deployed validator in `/home/celo/generate_pop.sh` which will generate the proof of possession for you.  Note that Geth will be stopped momentarily to generate the PoP, so don't run this on an active mainnet signer unless you know what you're doing.

8. Authorize the new signer

    Get the $SIGNER_PROOF_OF_POSSESSION and the $BLS_PUBLIC_KEY and the $BLS_PROOF_OF_POSSESSION as outputs from the generate_pop.sh script.
    Note that your address, signer and ledger index will need to match your environment.
    Todo: make this easier
    ```
    celocli account:authorize --from $CELO_VALIDATOR_ADDRESS --role validator --signature $SIGNER_PROOF_OF_POSSESSION \
    --signer $CELO_VALIDATOR_SIGNER_ADDRESS --blsKey $BLS_PUBLIC_KEY --blsPop $BLS_PROOF_OF_POSSESSION \
    --useLedger --ledgerCustomAddresses="[0]"
    ```

    Make sure that the new validator signer is fully synced before authorizing it.  It will take over signing duties at the epoch boundary.

## Monitoring
See logs: `sudo journalctl -xef -u celo_geth.service`

Monitoring is out of scope for this readme, but the [monitor_client](../monitor_client) role can be used to configure prometheus and loki to get telemetry for your celo validator.  See the [Celo Monitoring Guide](https://docs.celo.org/validator/monitoring) for more info.

## Troubleshooting
* Did you define the required variables?
* Is your ansible-vault configured properly?
* Is your DNS or /etc/hosts properly configured?

## Security
* Firewalling is *NOT* presently in-scope for this role.  You *DO* want your geth p2p port exposed publicly (tcp/udp 30303 by default), but you do *NOT* want your RPC port publicly exposed, particularly on a validator host.  The RPC isn't exposed by this role. If you need RPC services (public or otherwise), take a look at the [Celo Public RPC role](../celo_public_rpc).
* Your validator signer keys are stored encrypted on the filesystem, but so is the passphrase used to decrypt the key.
* As noted above, this role does not yet implement the sentry architecture which depends on "proxies" to communicate with our peers. This exposes your validator to denial of service attacks and generally speaking increases the vulnerability surface of the deployment.
The proxy/sentry architecture support may be added to this role at some point.
