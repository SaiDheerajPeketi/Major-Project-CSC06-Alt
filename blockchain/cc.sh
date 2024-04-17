# peer lifecycle chaincode package basic.tar.gz --lang java --label basic_1.0
# # ./network.sh up
# # ./network.sh createChannel -c mychannel
# ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java/ -ccl java



. scripts/envVar.sh
. scripts/utils.sh

presetup() {
    echo Installing npm packages ...
    pushd ../artifacts/chaincode/javascript
    npm install
    popd
    echo Finished installing npm dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="java"
VERSION="basic_1.0"
SEQUENCE=1
CC_SRC_PATH="../asset-transfer-basic/chaincode-java"
CC_NAME="basic"
CC_POLICY="NA"
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobals 1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}
# packageChaincode

installChaincode() {
    setGlobals 1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    CORE_PEER_ADDRESS=localhost:8051 peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peers ===================== "
}

# installChaincode

queryInstalled() {
    setGlobals 1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
    CORE_PEER_ADDRESS=localhost:8051 peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID1=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer1.org1 on channel ===================== "
}

# queryInstalled

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \

approveForMyOrg1() {
    setGlobals 1
    set -x
      peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" --channelID mychannel --name basc --version basc_1.0 --package-id ${PACKAGE_ID} --sequence ${SEQUENCE} ${INIT_REQUIRED} ${CC_POLICY} ${CC_COLL_CONFIG} >&log.txt
    set +x
     CORE_PEER_ADDRESS=localhost:8051 peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --signature-policy ${CC_POLICY} \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --package-id ${PACKAGE_ID1} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 1 ===================== "

}
# queryInstalled
# approveForMyOrg1

# --signature-policy "OR ('Org1MSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA
# --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles $PEER0_ORG2_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer')"

checkCommitReadyness() {
    setGlobals 1
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --signature-policy ${CC_POLICY} \
        --sequence ${SEQUENCE} --output json
    CORE_PEER_ADDRESS=localhost:8051 peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --signature-policy ${CC_POLICY} \
        --sequence ${SEQUENCE} --output json
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

# approveForMyOrg2() {
#     setGlobals 2

#     peer lifecycle chaincode approveformyorg -o localhost:7050 \
#         --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
#         --signature-policy ${CC_POLICY} \
#         --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
#         --version ${VERSION} --package-id ${PACKAGE_ID} \
#         --sequence ${SEQUENCE}

#     echo "===================== chaincode approved from org 2 ===================== "
# }

# queryInstalled
# approveForMyOrg2


commitChaincodeDefination() {
    setGlobals 1
    # peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
    #     --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    #     --signature-policy ${CC_POLICY} \
    #     --channelID $CHANNEL_NAME --name ${CC_NAME} \
    #     --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    #     --version ${VERSION} --sequence ${SEQUENCE}
        peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:8051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
}

# commitChaincodeDefination

queryCommitted() {
    setGlobals 1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}
    CORE_PEER_ADDRESS=localhost:8051 peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}


}

# queryCommitted

chaincodeInvoke() {
    setGlobals 1

    # Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        -c '{"function": "CreateContract","Args":["{\"id\":\"3\", \"test\":\"data\"}"]}'

}

# chaincodeInvoke


chaincodeQuery() {
    setGlobals 1
    peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
    CORE_PEER_ADDRESS=localhost:8051 peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

}

# chaincodeQuery




# Run this function if you add any new dependency in chaincode
# presetup

packageChaincode
installChaincode
queryInstalled
approveForMyOrg1
checkCommitReadyness
commitChaincodeDefination
queryCommitted
sleep 3
chaincodeInvoke
sleep 3
chaincodeQuery
