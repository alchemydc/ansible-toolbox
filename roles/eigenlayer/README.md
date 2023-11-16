# Eigenlayer role
This role will install and configure the system to be an operator on Eigenlayer DA

## Prerequisites
* Docker: Can be installed via this role: `ansible-playbook main.yml --tags "docker_server" -e "target=your_eigenlayer_node"`
* An Ethereum RPC provider: See https://www.alchemy.com/list-of/rpc-node-providers-on-ethereum if you don't have your own

## Variables
See vars/vars.yml.template and update as required

## Running the playbook
`ansible-playbook main.yml --tags "eigenlayer" -e "target=your_eigenlayer_node"`

## Post run manual tasks using the helper scripts
Run these from the host itself as the Eigenlayer user: `sudo su - eigenlayer``
1) Generate keys: `./helpers/create_keys.sh <key_name>`
2) Register an operator: `./helpers/register_operator.sh`

## Gotchas
1) Your metadata and logo need to be hosted somewhere reachable from the Internet. Hosting this static content it out of scope
for this role, but you can use gist.github.com for the metadata.json, and a public s3 or r2 bucket for the logo.
2) The logo must be png, not jpeg or anything else.
3) The operator account must be funded with some ETH on the network which you deploy to.
4) You may need to run the playbook again after you create_keys.sh and add the generated address to vars.yml. This will update the template .yml used by the register_operator.sh helper script.
5) You need 32 ETH delegated in order to do step 4 of the [operator setup process](https://docs.eigenlayer.xyz/operator-guides/avs-installation-and-registration/eigenda-operator-guide).  Unclear how to delegate ETH at this point.
6) Docker stack in the master branch of the operator repo fails to come up as of 16 nov 2023 with error: `error pulling image configuration: download failed after attempts=1: error parsing HTTP 408 response body: invalid character '<' looking for beginning of value: "<html><body><h1>408 Request Time-out</h1>\nYour browser didn't send a complete request in time.\n</body></html>\n"` while pulling the reverse-proxy layer.  Will try the last release tag.  That didn't work.  Suspect dockerhub is having issues. Will try again later.

## References
* [eigenda-operator-guide] (https://docs.eigenlayer.xyz/operator-guides/avs-installation-and-registration/eigenda-operator-guide)
* [grafana dashboards](https://github.com/Layr-Labs/eigenda-operator-setup/tree/master/dashboards)
