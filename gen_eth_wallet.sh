#!/usr/bin/env bash

if [[ -z "$1" ]]
then
 echo "Generate wallet: not enough arguments"
 echo ""
 echo "Usage:"
 echo " ./gen-wallet <wallet name>"
fi

if [[ -f ~/eth-wallets/${1} ]]
then
 echo "Error: wallet name already exists"
 exit 1;
fi

echo "Generate password for wallet"
pwgen -s 13 7 > ~/eth-wallets/${1}

echo "Generate the private and public keys"
openssl ecparam -name secp256k1 -genkey -noout |
    openssl ec -text -noout > ~/eth-wallets/${1}-key

echo "Extract the public key and remove the EC prefix 0x04"
cat ~/eth-wallets/${1}-key | grep pub -A 5 | tail -n +2 |
    tr -d '\n[:space:]:' | sed 's/^04//' > ~/eth-wallets/${1}-pub

echo "Extract the private key and remove the leading zero byte"
cat ~/eth-wallets/${1}-key | grep priv -A 3 | tail -n +2 |
    tr -d '\n[:space:]:' | sed 's/^00//' > ~/eth-wallets/${1}-priv

echo "Generate the hash and take the address part"
cat ~/eth-wallets/${1}-pub | keccak-256sum -x -l |
    tr -d ' -' | tail -c 41 > ~/eth-wallets/${1}-address

echo "Create new wallet"
geth account new --datadir ~/.ethereum-tmp --password ~/eth-wallets/${1} ~/eth-wallets/${1}-priv
rename UTC-- ${1}--UTC-- ~/.ethereum-tmp/keystore/UTC--* -v
mv ~/.ethereum-tmp/keystore/* ~/eth-wallets/