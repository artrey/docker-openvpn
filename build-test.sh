#!/bin/bash

NEW_UUID=test

docker build -t artrey/openvpn:$NEW_UUID . --no-cache
