./network.sh up createChannel -ca -c mychannel -s couchdb

./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java -ccl java

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

source ./scripts/envVar.sh 

setGlobals 1

peer chaincode invoke -n basic -C mychannel -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["CreateAsset","100","red","20","Aditya","100"]}'

peer chaincode query -n basic -C mychannel -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c '{"Args":["ReadAsset","100"]}' | jq .

./organizations/fabric-ca/registerPeer1Org1.sh 

docker-compose -f compose/docker/docker-compose-peer1org1.yaml up -d
