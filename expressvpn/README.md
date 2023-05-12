# ExpressVPN in a container

本容器应该作为基础镜像. 本项目源于基础镜像polkaned/expressvpn

添加了远程调用服务, 业务场景在于数据采集过程的IP池构建。可以作用于大文件资源下载, 数据高匿访问等场景。切勿尝试用于非法用途



## Prerequisites

1. 获取你的expressVPN激活号

## Docker Download

`docker pull pikadoramon/expressvpn`

## Start the container

    docker run \
      --env=ACTIVATION_CODE={% your-activation-code %} \
      --env=SERVER={% LOCATION/ALIAS/COUNTRY %} \
      --env=PREFERRED_PROTOCOL={% protocol %} \
      --env=LIGHTWAY_CIPHER={% lightway-cipher %} \
      --env=PROXY_PORT={% proxy-port %} \
      --cap-add=NET_ADMIN \
      --device=/dev/net/tun \
      --privileged \
      --detach=true \
      --tty=true \
      --name=expressvpn \
      -p {% proxy-port %}:{% proxy-port %} -p {% admin-proxy-port %}:{% admin-proxy-port %} \
      pikadoramon/expressvpn \
      /bin/bash


## Docker Compose
如果你想作为网络服务直接访问vpn网络, 可以尝试使用下面说明。这是原有polkaned/expressvpn带有的说明

Other containers can use the network of the expressvpn container by declaring the entry `network_mode: service:expressvpn`.
In this case all traffic is routed via the vpn container. To reach the other containers locally the port forwarding must be done in the vpn container (the network mode service does not allow a port configuration)

  ```
  expressvpn:
    container_name: expressvpn
    image: polkaned/expressvpn
    environment:
      - ACTIVATION_CODE={% your-activation-code %}
      - SERVER={% LOCATION/ALIAS/COUNTRY %}
      - PREFERRED_PROTOCOL={% protocol %}
      - LIGHTWAY_CIPHER={% lightway-cipher %}
    cap_add:
      - NET_ADMIN
    devices: 
      - /dev/net/tun
    stdin_open: true
    tty: true
    command: /bin/bash
    privileged: true
    restart: unless-stopped
    ports:
      # ports of other containers that use the vpn (to access them locally)
  
  downloader:
    image: example/downloader
    container_name: downloader
    network_mode: service:expressvpn
    depends_on:
      - expressvpn
  ```

## Configuration Reference

### ACTIVATION_CODE
A mandatory string containing your ExpressVPN activation code.

`ACTIVATION_CODE=ABCD1EFGH2IJKL3MNOP4QRS`

### SERVER
A optional string containing the ExpressVPN server LOCATION/ALIAS/COUNTRY. Connect to smart location if it is not set.

`SERVER=ukbe`

### PREFERRED_PROTOCOL
A optional string containing the ExpressVPN protocol. Can be auto, udp, tcp ,lightway_udp, lightway_tcp. Use auto if it is not set.

`PREFERRED_PROTOCOL=lightway_udp`

### LIGHTWAY_CIPHER
A optional string containing the ExpressVPN lightway cipher. Can be auto, aes, chacha20. Use auto if it is not set.

`LIGHTWAY_CIPHER=chacha20`

# Cases
附上案例展示说明

```
docker run  --env=ACTIVATION_CODE=ABCD1EFGH2IJKL3MNOP4QRS       --env=SERVER=us       --env=PROXY_PORT=50100       --cap-add=NET_ADMIN       --device=/dev/net/tun       --privileged       --detach=true       --tty=true   -p 50100:50100 -p 50099:50099   pikadoramon/expressvpn:latest
```

使用容器作为代理服务器
```
curl -x http://127.0.0.1:50100 --proxy-user crawler:GZOHPWN3EUpb https://httpbin.org/ip

{
  "origin": "216.24.210.119"
}

curl -x http://127.0.0.1:50100 --proxy-user crawler:GZOHPWN3EUpb https://httpbin.org/ip

{
  "origin": "103.163.220.48"
}

curl -x http://127.0.0.1:50100 --proxy-user crawler:GZOHPWN3EUpb https://httpbin.org/ip

{
  "origin": "103.163.220.31"
}

```

使用本容器提供代理管理API
```
GET http://127.0.0.1:50099/ok # 心跳检测.

GET http://127.0.0.1:50099/v1/expressvpn/status # 获取当前vpn状态
{"code":200,"data":{"CurrentStatus":"Not connected","CurrentCode":2,"CheckTime":"2023-05-12T03:48:02.837728283Z","Country":"","PrevCheckTIme":"2023-05-12T03:47:59.981022088Z","ActivateScript":"/opt/expressvpnactivate.sh","LightWayCipher":"auto","PreferredProtocol":"auto","Connecting":false},"msg":"succ"}

GET http://127.0.0.1:50099/v1/expressvpn/update?country=jp&lightWayCipher=auto&preferredProtocol=auto # 获取当前vpn状态参数, 再通过disconnect、connect方法即可更新vpn状态
{"code":200,"data":{"CurrentStatus":"Not connected","CurrentCode":2,"CheckTime":"2023-05-12T03:48:02.837728283Z","Country":"","PrevCheckTIme":"2023-05-12T03:47:59.981022088Z","ActivateScript":"/opt/expressvpnactivate.sh","LightWayCipher":"auto","PreferredProtocol":"auto","Connecting":false},"msg":"succ"}

GET http://127.0.0.1:50099/v1/expressvpn/disconnect # 断开当前VPN, 但是设置了每10s会重新连上一次
{"code":200,"data":{"CurrentStatus":"Not connected","CurrentCode":2,"CheckTime":"2023-05-12T03:54:45.733239023Z","Country":"","PrevCheckTIme":"2023-05-12T03:54:45.667323185Z","ActivateScript":"/opt/expressvpnactivate.sh","LightWayCipher":"auto","PreferredProtocol":"auto","Connecting":false},"msg":"succ"}


GET http://127.0.0.1:50099/v1/expressvpn/connect # 重新连接当前vpn状态
{"code":417,"data":{"CurrentStatus":"\u001b[1;32;49mConnected to Japan - Tokyo\u001b[0m   - If your VPN connection unexpectedly drops, internet traffic will be blocked to protect your privacy.   - To disable Network Lock, disconnect ExpressVPN then type 'expressvpn preferences set network_lock off'.","CurrentCode":1,"CheckTime":"2023-05-12T03:54:38.548933651Z","Country":"Japan - Tokyo","PrevCheckTIme":"2023-05-12T03:54:34.078130346Z","ActivateScript":"/opt/expressvpnactivate.sh","LightWayCipher":"auto","PreferredProtocol":"auto","Connecting":false},"msg":"already connect. if you want to connect another country, please disconnect."}

GET http://127.0.0.1:50099/v1/expressvpn/activate # 激活当前vpn
{"code":417,"data":{"CurrentStatus":"\u001b[1;32;49mConnected to Japan - Tokyo\u001b[0m   - If your VPN connection unexpectedly drops, internet traffic will be blocked to protect your privacy.   - To disable Network Lock, disconnect ExpressVPN then type 'expressvpn preferences set network_lock off'.","CurrentCode":1,"CheckTime":"2023-05-12T03:56:14.975501198Z","Country":"Japan - Tokyo","PrevCheckTIme":"2023-05-12T03:56:14.072665117Z","ActivateScript":"/opt/expressvpnactivate.sh","LightWayCipher":"auto","PreferredProtocol":"auto","Connecting":false},"msg":"already activate"}


POST http://127.0.0.1:50099/v1/expressvpn/reload # 重置当前vpn状态, 类似update和activate方法的结合

curl --location --request POST 'http://127.0.0.1:50099/v1/expressvpn/reload' \
--header 'Content-Type: application/json' \
--data-raw '{"code":"ADAAAAAAAA","country":"nz", "lightWayCipher":"auto", "preferredProtocol":"auto"}'

```