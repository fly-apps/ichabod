#!/bin/bash

paddr=$(grep fly-local-6pn /etc/hosts | cut -f 1)

function serf_server { 
  name="${FLY_APP_NAME}-${FLY_REGION}-$(hostname)"

  serf agent 					\
	-node="$name" 				\
	-bind="[$paddr]:7777"			\
	-tag role="${FLY_APP_NAME}"		\
	-event-handler=query:load=uptime
}

function serf_bringup { 
  while true ; do
    if ! serf info >/dev/null 2>&1 ; then
      sleep 0.25
      continue
    fi

    dig aaaa "${FLY_APP_NAME}.internal" +short | while read raddr ; do
      if [ "$raddr" != "$paddr" ]; then
        serf join "$raddr"
      fi
    done

    mems=$(serf members | wc -l)
    if [ "$mems" -lt 2 ]; then
      sleep 1
    else
      sleep 300
    fi
  done
}

cmd="$1"; shift
case "$cmd" in 
  server ) 
    serf_server $*
    ;;

  bringup ) 
    serf_bringup $*
   ;;

  * ) 
    echo "bad option $cmd"
    exit 1
   ;; 
esac
