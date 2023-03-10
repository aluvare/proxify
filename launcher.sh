sed -i "s#PROXYSTRING#${PROXY_STRING}#g" /etc/supervisor/conf.d/redirector.conf
if [[ "$FORCE_SSL" != "" ]];then
	sed -i "s/ -x=0/ -x=0 -allssl=1/g" /etc/supervisor/conf.d/redirector.conf
fi
if [[ "$TOR_DNS" != "" ]];then
	mv /etc/supervisor/conf.d/tor.* /etc/supervisor/conf.d/tor.conf
	echo LiB7CiAgICBiaW5kIDAuMC4wLjAKICAgIGZvcndhcmQgLiAxMjcuMC4wLjE6NTM1MwogICAgY2FjaGUKICAgIGxvZwogICAgZXJyb3JzCn0K|base64 -d > /opt/coredns/config/Corefile
fi
if [ -f /opt/redirector/iptables ];then
	bash /opt/redirector/iptables
fi
if [ -f /etc/wireguard/wg.conf ];then
	wg-quick up wg
else
	echo "You cannot work with this router if you dont have /etc/wireguard/wg.conf"
	exit 1
fi
if [[ "$PRECOMMAND" != "" ]];then
	echo $PRECOMMAND | base64 -d | bash
fi
ls /scripts/init-scripts|while read i;do bash /scripts/init-scripts/$i;done 
supervisord
