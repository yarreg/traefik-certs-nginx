#!/bin/bash


TRAEFIK_ACME_FILE=${TRAEFIK_ACME_FILE:-/traefik/acme.json}
INOTIFY_EVENTS=${INOTIFY_EVENTS:-modify}
CERTS_DIRECTORY=${CERTS_DIRECTORY-${TRAEFIK_ACME_FILE%/*}}


function run_nginx {
    while true; do
        echo "Dump traefik certs ..."
        dumpcerts.sh $TRAEFIK_ACME_FILE $CERTS_DIRECTORY

        echo "Starting nginx ..."
        nginx.sh
        sleep 2
    done
}


function run_watcher {
    while true; do
        inotifywait -e $INOTIFY_EVENTS $TRAEFIK_ACME_FILE
        if [ $? != 0 ]; then
            echo "Error waiting for notification: $TRAEFIK_ACME_FILE"
            sleep 2
            continue
        fi

        echo "Config file update detected"

        while true; do
            echo "Dump traefik certs ..."
            dumpcerts.sh $TRAEFIK_ACME_FILE $CERTS_DIRECTORY
            
            nginx -t
            if [ $? != 0 ]; then
                echo "ERROR: New configuration is invalid!!"
                sleep 2
            else
                echo "New configuration is valid, reloading nginx"
                nginx -s reload
                break
            fi
        done
    done
}


function waitany {
    while true; do
        for pid in "$@"; do
            kill -0 $pid 2>/dev/null            
            if [ $? = 0 ]; then
                sleep 2
                continue
            fi
            return 0
        done
    done
}


run_nginx &
PID1=$!

run_watcher &
PID2=$!

waitany $PID1 $PID2
exit 1
