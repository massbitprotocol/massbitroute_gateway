# Massbitroute Gateway

Component used for routing traffic to backend providers

## Run with Docker

examples

```
docker run -ti --rm  -e "MBR_ENV=shamu" -e "INSTALL_CMD=https://portal.massbitroute.net/api/v1/gateway_install?id=39d2c17f-c15b-4018-8cb8-4fdb41dd3f56&user_id=b363ddf4-42cf-4ccf-89c2-8c42c531ac99&blockchain=eth&network=mainnet&zone=EU&app_key=YNOaBzhTV5Gax6VT7r2BUg&portal_url=https://portal.massbitroute.net&env=shamu" massbit/massbitroute_gateway_dev:0.0.1-shamu-dev  -n
```
## System requirement

Currently, we only support Ubuntu 20.04 x64 with a minimum requirement of 4 vCPU and 4G RAM, 40GB free space

All commands require `root` permission. 

### Public IP Address

You must have your own public IP (ipv4) address when registering with the Massbit system. Massbit will forward traffic through this IP.

Check your public IP address with the command:
```
curl ipv4.icanhazip.com
```
### Firewall
Your gateway must open port 443 for HTTPS traffic.
You can check if your firewall is open 443 by the following step
For example, your IP is x.x.x.x
* From a gateway's terminal, open port 443 by netcat
```
apt install -y netcat
nc -l 443
```
if output is
```
nc: Address already in use
```
then you can check which process has opened it
```
netstat -tunalp |grep -i listen |grep :443
```

* Connect port 443 from public zone from another terminal
```
nc -vz x.x.x.x 443
```
If output is
```
Connection to 127.0.0.1 443 port [tcp/https] succeeded!
```
then your firewall is opened successfully

Or if the output is
```
nc: connect to 127.0.0.1 port 443 (tcp) failed: Connection refused
```
then you should check your firewall

## Install

### Clone source of this repo

```
mkdir -p /massbit/massbitroute/app/src/sites/services/gateway
git clone https://github.com/massbitprotocol/massbitroute_gateway.git /massbit/massbitroute/app/src/sites/services/gateway
cd /massbit/massbitroute/app/src/sites/services/gateway
./scripts/run _install
```

### Check gateway

* Verify node
```
cd /massbit/massbitroute/app/src/sites/services/gateway
./mbr gw nodeverify
```

if output is
```
{"result":true}
```
your gateway is successfully verified

* Check supervisor processes
```
 supervisorctl status
 ```
 the output should be
 ```
mbr_gateway                      RUNNING   pid 3469, uptime 62 days, 18:15:07
mbr_gateway_monitor              RUNNING   pid 3029099, uptime 30 days, 18:34:09
```
* Check gateway processes
```
cd /massbit/massbitroute/app/src/sites/services/gateway
./cmd_server status
```
the output should be
```
beanstalkd                       RUNNING   pid 3562, uptime 62 days, 18:14:13
monitor_client                   RUNNING   pid 327249, uptime 16 days, 17:12:10
nginx                            RUNNING   pid 1175590, uptime 28 days, 17:57:38
redis                            RUNNING   pid 3561, uptime 62 days, 18:14:13
```
* Check server configuration
```
cd /massbit/massbitroute/app/src/sites/services/gateway
./cmd_server nginx -t
```
the output should be
```
nginx: the configuration file /massbit/massbitroute/app/src/sites/services/gateway/tmp/nginx.conf syntax is ok
nginx: configuration file /massbit/massbitroute/app/src/sites/services/gateway/tmp/nginx.conf test is successful
```
* Check the debug logs
```
cd /massbit/massbitroute/app/src/sites/services/gateway
cat logs/debug.log
```

* If you still have problem, just send log for us and ask for help
```
cd /massbit/massbitroute/app/src/sites/services/gateway
./scripts/run _send_log
```
