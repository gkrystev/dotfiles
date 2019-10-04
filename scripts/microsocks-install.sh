#!/bin/bash

MICROSOCKS_ARCHIVE=http://ftp.barfooze.de/pub/sabotage/tarballs/microsocks-1.0.1.tar.xz
MICROSOCKS_FILE=${MICROSOCKS_ARCHIVE##*/}
MICROSOCKS_SERVICE=microsocks
MICROSOCKS_BIND_ADDRESS=0.0.0.0
#OVPN_NETWORK=10.100.0.0
#MICROSOCKS_BIND_ADDRESS=$(echo ${OVPN_NETWORK}|awk '{split($0,a,"[. ]"); print a[1]"."a[2]"."a[3]"."a[4]+1}')

echo "Prepare and install MicroSocks Socks server binary"
yum install -y gcc wget
cd /tmp
wget ${MICROSOCKS_ARCHIVE}
MICROSOCKS_DIR=`tar -xvf ${MICROSOCKS_ARCHIVE##*/} | head -n 1`
cd ${MICROSOCKS_DIR}
make
cp microsocks /usr/sbin/microsocks
chmod a+x /usr/sbin/microsocks

echo "Create MicroSocks service"
cat << __EOF > /etc/systemd/system/${MICROSOCKS_SERVICE}.service
[Unit]
Description=MicroSocks Socks Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/microsocks -i ${MICROSOCKS_BIND_ADDRESS}

[Install]
WantedBy=multi-user.target
__EOF

echo "Start and enable MicroSocks service"
systemctl daemon-reload
systemctl start ${MICROSOCKS_SERVICE}
systemctl enable ${MICROSOCKS_SERVICE}

echo "Clean template files"
rm -rf ${MICROSOCKS_DIR}
