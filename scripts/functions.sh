#!/bin/bash

function datef() {
    # Output:
    # Sat Jun  8 20:29:08 2019
    date "+%a %b %-d %T %Y"
}

function output() {
    >&2 echo "$(datef) - $1"
}

function createClient() {
    cd $APP_INSTALL_PATH

    CLIENT_FILENAME="${CLIENT_FILENAME:-client}"

    cp -r /etc/openvpn/pki.bak/ pki/

    # Redirect stderr to the black hole
    /usr/share/easy-rsa/easyrsa build-client-full "$CLIENT_FILENAME" nopass &> /dev/null
    # Writing new private key to '/usr/share/easy-rsa/pki/private/client.key
    # Client sertificate /usr/share/easy-rsa/pki/issued/client.crt
    # CA is by the path /usr/share/easy-rsa/pki/ca.crt

    INTERMEDIATE_DIR="clients/$CLIENT_FILENAME"
    # Create mkdir if doesn't exist
    mkdir -p "$INTERMEDIATE_DIR"

    cp "pki/private/$CLIENT_FILENAME.key" "pki/issued/$CLIENT_FILENAME.crt" pki/ca.crt /etc/openvpn/ta.key "$INTERMEDIATE_DIR"

    # Set default value to HOST_ADDR if it was not set from environment
    HOST_ADDR="${HOST_ADDR:-localhost}"

    # Set default value to HOST_PORT if it was not set from environment
    HOST_PORT="${HOST_PORT:-1194}"

    cp config/client.ovpn "$INTERMEDIATE_DIR"

    echo -e "\nremote $HOST_ADDR $HOST_PORT" >> "$INTERMEDIATE_DIR/client.ovpn"

    # Embed client authentication files into config file
    cat <(echo -e '<ca>') \
        "$INTERMEDIATE_DIR/ca.crt" <(echo -e '</ca>\n<cert>') \
        "$INTERMEDIATE_DIR/$CLIENT_FILENAME.crt" <(echo -e '</cert>\n<key>') \
        "$INTERMEDIATE_DIR/$CLIENT_FILENAME.key" <(echo -e '</key>\n<tls-auth>') \
        "$INTERMEDIATE_DIR/ta.key" <(echo -e '</tls-auth>') \
        >> "$INTERMEDIATE_DIR/client.ovpn"
    
    cp "$INTERMEDIATE_DIR/client.ovpn" "/etc/openvpn/clients/$CLIENT_FILENAME.ovpn"

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
    if [ ! -z "$STATIC_CLIENT_IP" -a ! -z "$STATIC_SERVER_IP" ]
    then
        echo -e "ifconfig-push $STATIC_CLIENT_IP $STATIC_SERVER_IP" > "/etc/openvpn/ccd/$CLIENT_FILENAME"
    fi

    output "$CLIENT_FILENAME.ovpn file has been generated (see folder /etc/openvpn/clients)"
}

function generateServerParameters() {
    /usr/share/easy-rsa/easyrsa init-pki
    
    /usr/share/easy-rsa/easyrsa gen-dh
    # DH parameters of size 2048 created at /usr/share/easy-rsa/pki/dh.pem
    # Copy DH file
    cp pki/dh.pem /etc/openvpn

    /usr/share/easy-rsa/easyrsa build-ca nopass << EOF

EOF
    # CA creation complete and you may now import and sign cert requests.
    # Your new CA certificate file for publishing is at:
    # /usr/share/easy-rsa/pki/ca.crt

    /usr/share/easy-rsa/easyrsa gen-req MyReq nopass << EOF2

EOF2
    # Keypair and certificate request completed. Your files are:
    # req: /usr/share/easy-rsa/pki/reqs/MyReq.req
    # key: /usr/share/easy-rsa/pki/private/MyReq.key

    /usr/share/easy-rsa/easyrsa sign-req server MyReq << EOF3
yes
EOF3
    # Certificate created at: /usr/share/easy-rsa/pki/issued/MyReq.crt

    openvpn --genkey --secret /etc/openvpn/ta.key << EOF4
yes
EOF4

    # Print app version
    output "Server $APP_NAME configured"

    # Copy server keys and certificates
    cp pki/ca.crt pki/issued/MyReq.crt pki/private/MyReq.key /etc/openvpn

    # Copy backup of pki
    cp -r pki/ /etc/openvpn/pki.bak/
}
