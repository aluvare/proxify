FROM ubuntu:jammy AS builder

RUN DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive DEBIAN_FRONTEND=noninteractive apt install gcc g++ make git golang-go -y
RUN cd /opt/ && git clone https://github.com/ryanchapman/go-any-proxy.git && cd /opt/go-any-proxy && ./make.bash
RUN cd /opt/ && git clone https://github.com/coredns/coredns && cd /opt/coredns && make

FROM ubuntu:jammy AS final

RUN DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive apt install iptables supervisor netcat net-tools ulogd2 libcap2-bin -y && mkdir -p /opt/any_proxy /opt/coredns/config /scripts/init-scripts

COPY --from=builder /opt/go-any-proxy/any_proxy /opt/any_proxy/
COPY --from=builder /opt/coredns/coredns /opt/coredns/
ADD conf/supervisor/ /etc/supervisor/conf.d/
ADD conf/iptables /opt/any_proxy/iptables
ADD conf/ulogd /etc/ulogd.conf
ADD conf/coredns/ /opt/coredns/config/
ADD launcher.sh /scripts/launcher.sh

RUN useradd anyproxy --uid 1000 && \
	useradd coredns --uid 1001 && \
	chown 1000.1000 -R /opt/any_proxy && \
	setcap CAP_NET_BIND_SERVICE=+eip /opt/coredns/coredns 

RUN echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
RUN echo 'net.ipv4.ip_forward=1\n\
net.core.netdev_max_backlog = 2048\n\
net.core.somaxconn = 1024\n\
net.core.rmem_default = 8388608\n\
net.core.rmem_max = 16777216\n\
net.core.wmem_max = 16777216\n\
net.ipv4.ip_local_port_range = 2000 65000\n\
net.ipv4.tcp_window_scaling = 1\n\
net.ipv4.tcp_max_syn_backlog = 3240000\n\
net.ipv4.tcp_max_tw_buckets = 1440000\n\
net.ipv4.tcp_mem = 50576 64768 98152\n\
net.ipv4.tcp_rmem = 4096 87380 16777216\n\
net.ipv4.tcp_syncookies = 1\n\
net.ipv4.tcp_wmem = 4096 65536 16777216\n\
net.ipv4.tcp_congestion_control = cubic' >> /etc/sysctl.conf && ulimit -n 65535 && groupadd proxified

#RUN apt clean autoclean && apt autoremove --yes && rm -rf /var/lib/{apt,dpkg,cache,log}/

ADD init-scripts/ /scripts/init-scripts/

HEALTHCHECK --interval=30s --timeout=5s CMD nc -vz 127.0.0.1 12345
ENTRYPOINT bash /scripts/launcher.sh