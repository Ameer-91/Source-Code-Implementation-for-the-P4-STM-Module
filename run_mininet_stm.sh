#!/bin/bash

# Set paths
P4SRC=../p4/p4_stm.p4
JSON=../config/p4_stm.json
P4INFO=../config/p4_stm.p4info.txt

# Compile P4 program
echo "Compiling P4 program..."
p4c-bm2-ss --target bmv2 --arch v1model   --p4runtime-files $P4INFO -o $JSON $P4SRC

# Launch BMv2 switch
echo "Starting BMv2 switch with gRPC..."
simple_switch_grpc --device-id 0 --log-console -i 0@veth0 -i 1@veth1 $JSON &
sleep 2

# Launch controller (Python gRPC)
echo "Launching P4Runtime controller..."
cd ../control
python3 controller.py &
cd -
sleep 2

# Launch Mininet topology
echo "Starting Mininet..."
sudo python3 ../topology/topology.py

# Clean up background processes on exit
trap "killall simple_switch_grpc; killall python3" EXIT
