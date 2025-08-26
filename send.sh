#!/bin/bash

send_requests() {
    while true; do
        curl -sS http://44.204.138.237:32144 > /dev/null
        echo "Request sent"
        sleep 0.0667  
    done
}

for ((i=1; i<=15; i++)); do
    send_requests &
    pids[$i]=$!
done

trap 'echo "Exiting..."; kill ${pids[*]}; exit' INT

wait
