#!/bin/bash
docker volume create k8s-hands-on
docker container run --rm -it \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -v k8s-hands-on:/root/config \
     -p 8080:8080 sakajunquality/k8s-hands-on
