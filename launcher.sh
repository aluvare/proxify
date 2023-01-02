sed -i "s/PROXYSTRING/${PROXY_STRING}/g" /etc/supervisor/conf.d/any_proxy.conf
iptables-restore < /opt/any_proxy/iptables
ls /scripts/init-scripts|while read i;do bash /scripts/init-scripts/$i;done 
supervisord
