function start(){
    echo "Starting blockchain"
    cd ./blockchain
    ./app_start.sh
    cd ..
    echo "Started Successfully"
}

function stop(){
    echo "Stopping blockchain"
    cd ./blockchain
    ./network.sh down
    cd ..
    echo "Stopped Successfully"
}

function test(){
    cd ./caliper-workspace
    npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmark.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled
    cd ..
}

if [ $1 == "start" ]
then
start
elif [ $1 == "stop" ]
then
stop
elif [ $1 == "test" ]
then
test
else 
echo "No such command"
fi
