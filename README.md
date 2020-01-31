<p align=center><img src="https://alekslitvinenk.github.io/docker-openvpn/assets/img/logo-s.png"></p><br>

[![Docker Pulls](https://img.shields.io/docker/pulls/artrey/openvpn.svg)](https://hub.docker.com/r/artrey/openvpn/)
![GitHub](https://img.shields.io/github/license/artrey/docker-openvpn)

# 🔐Docker-OpenVPN

## GitHub Repo:

https://github.com/artrey/docker-openvpn

## DockerHub Repo:

https://hub.docker.com/r/artrey/openvpn

# Quick Start 🚀

### Prerequisites:

1. Any hardware or vps server running Linux. You should have administrative rights on this machine.
2. Docker installation on your server.
3. Public ip address assigned to your server.

## 1. Prepare docker-openvpn server

```bash
# create data folder
mkdir ovpn-data

# generate server credentials
docker run --rm -it \
	-v $PWD/ovpn-data/:/etc/openvpn/ \
	artrey/openvpn:test gen-server
```

## 2. Generate client credentials

Environment variables:

- `HOST_ADDR` - addres of your vpn server
- `HOST_PORT` - port for client (server works on port 1194). It useful for mapping ports (see step 3).
- `CLIENT_FILENAME` - unique name of client
- `STATIC_CLIENT_IP` (optional) - reserve the ip for this client (10.8.0.x)
- `STATIC_SERVER_IP` (optional) - reserve the server side ip for this client (10.8.0.x)

Valid map of static ips:

```bash
    # Available static ips (pair client-server)
    # [  1,  2] [  5,  6] [  9, 10] [ 13, 14] [ 17, 18]
    # [ 21, 22] [ 25, 26] [ 29, 30] [ 33, 34] [ 37, 38]
    # [ 41, 42] [ 45, 46] [ 49, 50] [ 53, 54] [ 57, 58]
    # [ 61, 62] [ 65, 66] [ 69, 70] [ 73, 74] [ 77, 78]
    # [ 81, 82] [ 85, 86] [ 89, 90] [ 93, 94] [ 97, 98]
    # [101,102] [105,106] [109,110] [113,114] [117,118]
    # [121,122] [125,126] [129,130] [133,134] [137,138]
    # [141,142] [145,146] [149,150] [153,154] [157,158]
    # [161,162] [165,166] [169,170] [173,174] [177,178]
    # [181,182] [185,186] [189,190] [193,194] [197,198]
    # [201,202] [205,206] [209,210] [213,214] [217,218]
    # [221,222] [225,226] [229,230] [233,234] [237,238]
    # [241,242] [245,246] [249,250] [253,254]
```

Example of command:

```bash
# generate client credentials
docker run --rm -it \
	-v $PWD/ovpn-data/:/etc/openvpn/ \
	-e HOST_ADDR=$(curl -s https://api.ipify.org) \
	-e HOST_PORT=45045 \
	-e CLIENT_FILENAME=client \
	-e STATIC_CLIENT_IP=10.8.0.5 \
	-e STATIC_SERVER_IP=10.8.0.6 \
	artrey/openvpn:test gen-client
```

## 3. Configure ports and start

Example of `docker-compose.yml`:

```yml
version: "3"

services:
  ovpn:
    image: artrey/openvpn:latest
    restart: unless-stopped
    volumes:
      - ./ovpn-data/:/etc/openvpn/
      - ./socat-mapping.sh:/socat-mapping.sh
    cap_add:
      - NET_ADMIN
    ports:
      - 45045:1194/udp
      - 9000:9000
      - etc.
```

Example of `socat-mapping.sh` (optional):

```bash
socat TCP-LISTEN:9000,reuseaddr,fork TCP:10.8.0.5:9000 &
```

Start OpenVPN

```bash
docker-compose up -d
```

# [License Agreement](https://github.com/artrey/docker-openvpn/blob/master/LICENSE)
