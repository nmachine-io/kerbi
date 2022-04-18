#!/bin/bash

docker build . -t test-image:1.0.0

docker run \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --net=host \
        us-central1-docker.pkg.dev/nectar-bazaar/public/kind-test-runner:0.0.2
