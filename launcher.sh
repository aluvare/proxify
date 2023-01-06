sed -i "s/PROXYSTRING/${PROXY_STRING}/g" /etc/supervisor/conf.d/redirector.conf
if [ -f /opt/redirector/iptables ];then
	bash /opt/redirector/iptables
fi
if [ -f /etc/wireguard/wg.conf ];then
	wg-quick up wg
else
	echo "You cannot work with this router if you dont have /etc/wireguard/wg.conf"
	exit 1
fi
ls /scripts/init-scripts|while read i;do bash /scripts/init-scripts/$i;done 
supervisord
