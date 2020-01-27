#!/bin/bash

source ./functions.sh

if [[ "$1" -eq "gen-server" ]]; then
    generateServerParameters
    exit 0
fi

if [[ "$1" -eq "gen-client" ]]; then
    createClient
    exit 0
fi

mkdir -p /dev/net

if [ ! -c /dev/net/tun ]; then
    echo "$(datef) Creating tun/tap device."
    mknod /dev/net/tun c 10 200
fi

# Allow UDP traffic on port 1194.
iptables -A INPUT -i eth0 -p udp -m state --state NEW,ESTABLISHED --dport 1194 -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED --sport 1194 -j ACCEPT

# Allow traffic on the TUN interface.
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tun0 -o eth0 -s 10.8.0.0/24 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -s 172.17.0.0/16 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT
iptables -A INPUT -i tun0 -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

chmod +x /socat-mapping.sh && /socat-mapping.sh

# Need to feed key password
openvpn --config /etc/openvpn/server.conf
