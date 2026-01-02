#!/bin/bash

# Example Lambda handler function
run () {
    # curl -sS \
    #     httpbin.org/get 
    sleep 10  # Force Lambda to spin up new containers for concurrent requests
    echo "Hello World!"
}

# run "$@"

# Call handler with event data
# handler "$@"