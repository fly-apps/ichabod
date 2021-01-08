#!/bin/bash
set -e

LOCAL_ADDRESS=$(grep fly-local-6pn /etc/hosts | cut -f 1)

# first arg is `http` or `--some-option`
if [[ "$1" == http* ]] || [[ "$1" == -* ]] || [[ "about:blank" == "$1" ]] || [[ "$#" == 0 ]]; then
    set -- chromium --headless --disable-gpu --remote-debugging-address=${LOCAL_ADDRESS} --remote-debugging-port=$CHROME_DEBUG_PORT --no-sandbox "$@"
fi
exec "$@"
