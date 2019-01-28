#!/usr/bin/env bash

WALLET=$1

if [[ -z ${WALLET} ]]
then
 echo "Generate wallet: not enough arguments"
 echo ""
 echo "Usage:"
 echo " ./gen-wallet <wallet name>"
 exit 1;
fi

ROOT=${PWD}
#ROOT=~
DIR=${ROOT}/tron-wallets/${WALLET}

if [[ -d ${DIR} ]]
then
 echo "Error: wallet name already exists"
 exit 1;
else
  if [[ ! -d "${ROOT}/tron-wallets" ]]
  then
    mkdir ${ROOT}/tron-wallets
  fi
 mkdir ${DIR}
fi

#echo "Generate password for wallet"
pwgen -s 13 7 > ${DIR}/${WALLET}-pass

#echo "Generate a key pair and extract the public key (a 64-byte byte array representing its x,y coordinates)."
openssl ecparam -name secp256k1 -genkey -noout | openssl ec -text -noout > ${DIR}/${WALLET}-key

PRIVATEKEY=$( cat ${DIR}/${WALLET}-key | grep priv -A 3 | tail -n +2 | tr -d '\n[:space:]:' )
echo "private key: "${PRIVATEKEY}

PUBLICKEY=$( cat ${DIR}/${WALLET}-key | grep pub -A 5 | tail -n +2 | tr -d '\n[:space:]:' | sed 's/^04//' )
echo "public key: 04"${PUBLICKEY}

#echo "Hash the public key using sha3-256 function and extract the last 20 bytes of the result."
KECCAK256=$( echo -n ${PUBLICKEY} | keccak-256sum -x -l | tr -d ' -' )
echo "sha3: "${KECCAK256}

#echo "Add 41 to the beginning of the byte array. Length of the initial address should be 21 bytes."
ADDRESS="41$(echo -n ${KECCAK256} | cut -c25-64 )"
#echo "Address: "${ADDRESS}

#echo "Hash the address twice using sha256 function and take the first 4 bytes as verification code."
SHA256_0=$( echo -n ${ADDRESS} | xxd -r -p | sha256sum | tr -d ' -' )
#echo "sha256_0: "${SHA256_0}

SHA256_1=$( echo -n ${SHA256_0} | xxd -r -p | sha256sum | tr -d ' -' )
#echo "sha256_1: "${SHA256_1}

CHECKSUM=$( echo -n ${SHA256_1} | cut -c1-8 )
#echo ${CHECKSUM}


#echo "Add the verification code to the end of the initial address and get an address in base58check format through base58 encoding."
ADDCHECKSUM=${ADDRESS}${CHECKSUM}
#echo "addchecksum: ${ADDCHECKSUM}"


source ./utils.sh
#echo "An encoded mainnet address begins with T and is 34 bytes in length."
BASE58=$(encodeBase58 ${ADDCHECKSUM})
echo "base68encoded: "${BASE58}
echo ${BASE58} > ${DIR}/${WALLET}-base58address

echo "address: "${ADDRESS}
echo ${ADDRESS} > ${DIR}/${WALLET}-address

echo "public-key: 04${PUBLICKEY}"
echo "04${PUBLICKEY}" > ${DIR}/${WALLET}-public

echo ${PRIVATEKEY} > ${DIR}/${WALLET}-private







