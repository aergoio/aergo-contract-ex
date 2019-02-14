#! /bin/bash

buildSeq=(
    'safemath'  
    'address'
    'object'
    'typecheck'
    'roles/minter'
    'helloworld'
    'fixedtoken'
    'exchange'
    'crowdsale'
    'token'
)

ROOTDIR="$(dirname ${BASH_SOURCE[0]})"

for CONTRACTDIR in "${buildSeq[@]}" 
do
    echo ''
    echo '[Deploy Contract' $CONTRACTDIR']'
    pushd $ROOTDIR/../contracts/$CONTRACTDIR
    ship build
    ship publish
    popd
done
