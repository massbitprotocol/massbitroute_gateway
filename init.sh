#!/bin/bash
# apt update
# apt install -y python-is-python2 supervisor
auth=massbit:41d919e74993945a97972d147c4d01847e8bc1b6
mkdir -p /massbit/massbitroute/app/
if [ ! -d "/massbit/massbitroute/app/gbc/.git" ]; then
	git clone http://$auth@git.massbitroute.com/massbitroute/gbc.git /massbit/massbitroute/app/gbc
fi
ln -sf /massbit/massbitroute/app/gbc/bin/openresty /usr/local/

if [ ! -d " /etc/letsencrypt/.git" ]; then
	git clone http://$auth@git.massbitroute.com/massbitroute/ssl.git /etc/letsencrypt
fi

cd $(dirname $(realpath $0))
git pull origin master
ln -sf /massbit/massbitroute/app/gbc
ln -sf gbc/bin
mkdir -p tmp db logs
ln -sf gbc/start_server
ln -sf gbc/stop_server
ln -sf gbc/cmd_server
if [ -d "/etc/supervisor/conf.d" ]; then
	cp supervisor.conf /etc/supervisor/conf.d/gateway.conf
elif [ -d "/etc/supervisord.d" ]; then
	systemctl enable supervisord
	systemctl start supervisord
	cp supervisor.conf /etc/supervisord.d/gateway.conf
fi

rm -rf logs/*.log logs/nginx/*.log db/* tmp/*
supervisorctl update
