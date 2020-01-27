#!/usr/bin/env bash

docker run --cap-add=NET_ADMIN \
	-p 1194:1194/udp \
	-e HOST_ADDR=localhost -e HOST_PORT=1194 \
	--name vpn-server-test \
	artrey/openvpn:test "$@"
