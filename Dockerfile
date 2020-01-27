FROM alpine:3.11.3

LABEL maintainer="Alexander Ivanov <oz.sasha.ivanov@gmail.com>"

ENV APP_NAME dockovpn
ENV APP_INSTALL_PATH /opt/${APP_NAME}

WORKDIR ${APP_INSTALL_PATH}

COPY scripts .
COPY config ./config

RUN apk add --no-cache openvpn easy-rsa bash dumb-init socat && \
	# socat is utility for port mapping (iptables not working correctly in docker)
	cp config/server.conf /etc/openvpn/server.conf && \
    mkdir -p /etc/openvpn/ccd && \
    mkdir -p /etc/openvpn/clients

EXPOSE 1194/udp

ENTRYPOINT ["dumb-init", "./start.sh"]
