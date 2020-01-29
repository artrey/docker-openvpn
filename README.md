<p align=center><img src="https://alekslitvinenk.github.io/docker-openvpn/assets/img/logo-s.png"></p><br>

<p align="center">
<a href="https://github.com/alekslitvinenk/docker-openvpn/blob/master/README.md">[English]</a>
<a href="https://github.com/alekslitvinenk/docker-openvpn/blob/master/docs/README_RU.md">[Русский]</a>
<br>

![Build Status](http://cicd.dockovpn.io/build/docker-openvpn)
![Build Time](http://cicd.dockovpn.io/built/docker-openvpn)
[![Docker Pulls](https://img.shields.io/docker/pulls/alekslitvinenk/openvpn.svg)](https://hub.docker.com/r/alekslitvinenk/openvpn/)
[![Gitter chat](https://img.shields.io/badge/chat-on_gitter-50b6bb.svg)](https://gitter.im/docker-openvpn/community)
![GitHub](https://img.shields.io/github/license/alekslitvinenk/docker-openvpn)

# 🔐Docker-OpenVPN
Out of the box stateless openvpn server docker image which starts in just a few seconds and doesn't require presistent storage.

## GitHub Repo:
https://github.com/alekslitvinenk/docker-openvpn

## DockerHub Repo:
https://hub.docker.com/r/alekslitvinenk/openvpn

### Docker Tags
| Tag    | Description | 
| :----: | :---------: |
| `latest` | This tag is added to every newly built version be that `v#.#.#` or `v#.#.#-regen-dh` |
| `v#.#.#` | Standard fixed release version, where {1} is _major version_, {2} - _minor_ and {3} is a _patch_. For instance, `v1.1.0` |
| `v#.#.#-regen-dh` | Release version with newly generated Deffie Hellman security file. In order to keep security high this version is generated every hour. Tag example - `v1.1.0-regen-dh` |
| `dev` | Development build which contains the most recent changes from the active development branch (master) |

# Video Guide 📹
<p align=center><a href="https://youtu.be/y5Dwakc6hMs"><img src="https://alekslitvinenk.github.io/docker-openvpn/assets/img/video-cover-play.png"></a></p><br>

# Quick Start 🚀

### Prerequisites:
1. Any hardware or vps server running Linux. You should have administrative rights on this machine.
2. Docker installation on your server.
3. Public ip address assigned to your server.

## 1. Run docker-openvpn
Copy & paste the following command to run docker-openvpn:<br>
```bash
docker run --cap-add=NET_ADMIN \
-p 1194:1194/udp -p 80:8080/tcp \
-e HOST_ADDR=$(curl -s https://api.ipify.org) \
alekslitvinenk/openvpn
```

If everything went well, you should be able to see the following output in your console:
```
Sun Jun  9 08:56:11 2019 Initialization Sequence Completed
Sun Jun  9 08:56:12 2019 Client.ovpn file has been generated
Sun Jun  9 08:56:12 2019 Config server started, download your client.ovpn config at http://example.com:8080/
Sun Jun  9 08:56:12 2019 NOTE: After you download you client config, http server will be shut down!
 ```
## 2. Get client configuration
Now, when your docker-openvpn is up and running you can go to `<your_host_public_ip>:8080` on your device and download ovpn client configuration.
As soon as you have your config file downloaded, you will see the following output in the console:<br>
```
Sun Jun  9 09:01:15 2019 Config http server has been shut down
```
Import `client.ovpn` into your favourite openvpn client. In most cases it should be enough to just doubleclick or tap on that file.


## 3. Connect to your docker-openvpn container
You should be able to see your newly added client configuration in the list of available configurations. Click on it, connection process should initiate and be established withing few seconds.

Congratulations, now you're all set and can safely browse the internet.

# Other resources
[Contrubition Guidelines](https://github.com/alekslitvinenk/docker-openvpn/blob/master/CONTRIBUTING.md)<br>
[Code Of Conduct](https://github.com/alekslitvinenk/docker-openvpn/blob/master/CODE_OF_CONDUCT.md)<br>
[License Agreement](https://github.com/alekslitvinenk/docker-openvpn/blob/master/LICENSE)

```bash
# create data folder
mkdir ovpn-data

# generate server credentioals
docker run --rm -it \
	-v $PWD/ovpn-data/:/etc/openvpn/ \
	artrey/openvpn:test gen-server

# generate client credentials
docker run --rm -it \
	-v $PWD/ovpn-data/:/etc/openvpn/ \
	-e HOST_ADDR=$(curl -s https://api.ipify.org) \
	-e HOST_PORT=1194 \
	-e CLIENT_FILENAME=client \
	-e STATIC_CLIENT_IP=10.8.0.5 \
	-e STATIC_SERVER_IP=10.8.0.6 \
	artrey/openvpn:test gen-client

# start OpenVPN (don't forget update socat-mapping.sh)
docker-compose up -d
```
