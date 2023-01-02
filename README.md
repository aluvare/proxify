# proxify

This project uses https://github.com/ryanchapman/go-any-proxy as transparent proxy server.

More info about the project at https://blog.rchapman.org/posts/Transparently_proxying_any_tcp_connection/

The proxy string is the same as the -p parameter in any_proxy. 

Some examples here:
```
MyLogin:Password25@proxy.corporate.com:8080
1.2.3.4:80,1.2.3.5:80,1.2.3.6:80
```

Example:
```
version: "2.3"
services:
  kali:
    image: ghcr.io/aluvare/kalidocker-vnc-lite/kalidocker-vnc-lite
    restart: always
    healthcheck:
      interval: 10s
      retries: 12
      test: nc -vz 127.0.0.1 5900
    cap_add:
      - NET_ADMIN
  novnc:
    image: ghcr.io/aluvare/easy-novnc/easy-novnc
    restart: always
    depends_on:
      - kali
    command: --addr :8080 --host kali --port 5900 --basic-ui --no-url-password --novnc-params "resize=remote"
    ports:
      - "8080:8080"
  router:
    image: ghcr.io/aluvare/proxify/proxify
    restart: always
    privileged: true
    environment:
      - "PROXY_STRING=MyLogin:Password25@proxy.corporate.com:8080"
    cap_add:
      - NET_ADMIN
```

In the example to use the transparent proxy, you need to use your browser to 127.0.0.1:8080, open a shell in the kali desktop, and run:
```
sudo su -
rip=$(host router|awk '{print $NF}') && ip route delete default && ip route add default via $rip && echo "nameserver $rip" >/etc/resolv.conf
```
