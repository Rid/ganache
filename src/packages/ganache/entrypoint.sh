#!/bin/bash

if [ ! -f /etc/installer_completed ]; then
    until [[ $(curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST "https://api.appsolo.com/v1/apps/installed/${INSTANCE_ID}" | grep ' 200 ') ]]
        do
        sleep 5
    done
    touch /etc/installer_completed
fi

exec "node" "/app/dist/node/cli.js" "-h" "0.0.0.0" "-p" "${PORT}" "--account_keys_path" "/appstore/keys.json" "-a" "1000" "-s" "${SEED}" "-i" "1337"