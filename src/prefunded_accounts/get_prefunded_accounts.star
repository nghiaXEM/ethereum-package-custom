new_prefunded_account = import_module(
    "../prelaunch_data_generator/genesis_constants/genesis_constants.star"
)

IMAGE = "wealdtech/ethereal:latest"


def get_accounts(plan, mnemonic, num_of_keys=0):
    PRE_FUNDED_ACCOUNTS = []
    plan.print("mnemonic: {0}".format(mnemonic))
    for current_key in range(num_of_keys):
        private_key_service_name = "run-ethereal-private-key-{0}".format(current_key)
        eth_address_service_name = "run-ethereal-eth-address-{0}".format(current_key)

        private_key = plan.run_sh(
            name=private_key_service_name,
            image=IMAGE,
            description="Running ethereal to derive private keys of key {0}".format(
                current_key
            ),
            run="private_key=$(/app/ethereal hd keys --seed=\"{0}\" --path=\"m/44'/60'/0'/0/{1}\" | awk '/Private key/{{print substr($NF, 3)}}'); echo -n $private_key".format(
                mnemonic, current_key
            ),
        )
        eth_address = plan.run_sh(
            name=eth_address_service_name,
            image=IMAGE,
            description="Running ethereal to derive eth address of key {0}".format(
                current_key
            ),
            run="eth_addr=$(/app/ethereal hd keys --seed=\"{0}\" --path=\"m/44'/60'/0'/0/{1}\" | awk '/Ethereum address/{{print $NF}}'); echo -n $eth_addr".format(
                mnemonic, current_key
            ),
        )

        PRE_FUNDED_ACCOUNTS.append(
            new_prefunded_account.new_prefunded_account(
                eth_address.output, private_key.output
            )
        )

    plan.print("PRE_FUNDED_ACCOUNTS: {0}".format(PRE_FUNDED_ACCOUNTS))

    return PRE_FUNDED_ACCOUNTS
