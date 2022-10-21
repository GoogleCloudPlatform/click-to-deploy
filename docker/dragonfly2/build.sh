#!/bin/bash

docker build -t dragonfly-dfget  2/debian11/dragonfly-dfget/2.0/
docker build -t dragonfly-manager  2/debian11/dragonfly-manager/2.0/
docker build -t dragonfly-scheduler  2/debian11/dragonfly-scheduler/2.0/
docker build -t dragonfly-seed-peer  2/debian11/dragonfly-seed-peer/2.0/
