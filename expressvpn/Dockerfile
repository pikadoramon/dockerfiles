# Run expressvpn in a container
# 该镜像是创建一个expressvpn container
# debian轻量级, 适合docker打包
FROM debian:bullseye-slim

LABEL maintainer="samuel"

ENV PROXY_PORT 50100
ENV ACTIVATION_CODE Code
ENV LOCATION smart
ENV PREFERRED_PROTOCOL auto
ENV LIGHTWAY_CIPHER auto

# 指定vpn版本
# https://www.expressvpn.works/clients/linux/expressvpn_3.48.0.4-1_amd64.deb
ARG APP=expressvpn_3.48.0.4-1_amd64.deb
COPY ./files/groxy /opt/groxy
COPY ./files/vpncheck.sh /opt/vpncheck.sh
COPY ./files/entrypoint.sh /opt/entrypoint.sh
COPY ./files/expressVPNActivate.sh /opt/expressvpnactivate.sh
COPY ./files/${APP} /opt/${APP}

RUN apt-get update && apt-get install -y --no-install-recommends \
    libterm-readkey-perl ca-certificates wget expect iproute2 iputils-ping curl procps libnm0 \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg -i /opt/${APP} \
    && rm -rf /opt/*.deb \
    && apt-get purge -y --auto-remove wget

RUN chmod 777 /opt/groxy
CMD ["/bin/bash", "/opt/entrypoint.sh"]
