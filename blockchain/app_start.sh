
./network.sh up
./network.sh up createChannel -c mychannel -ca 
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-java/ -ccl java
cd scripts
./org1_cc_env.sh
cd ..
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
cd ..
cd asset-transfer-basic/application-gateway-java/
gradle build
gradle run
cd ../../blockchain
