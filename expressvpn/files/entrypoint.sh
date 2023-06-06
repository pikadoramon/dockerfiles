#!/usr/bin/bash
echo 启动expressvpn

cp /etc/resolv.conf /opt/resolv.conf
su -c 'umount /etc/resolv.conf'
cp /opt/resolv.conf /etc/resolv.conf
sed -i 's/DAEMON_ARGS=.*/DAEMON_ARGS=""/' /etc/init.d/expressvpn
service expressvpn restart

expressvpn preferences set auto_connect true
expressvpn preferences set preferred_protocol $PREFERRED_PROTOCOL
expressvpn preferences set lightway_cipher $LIGHTWAY_CIPHER

echo start go-proxy version v0.0.1 on port $PROXY_PORT
chmod 777 /opt/full_groxy
/opt/full_groxy -P=$PROXY_PORT
exec "$@"
