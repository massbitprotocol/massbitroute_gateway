# Massbitroute Gateway

Component using for routing traffic between all backend providers


## System requirement

Currently we tested only Ubuntu 20.04 x64. Minimum requirement is 4 vCPU and 4G RAM, 40GB free space

### Public IP Address

You must have own public IP (ipv4) address when register with Massbit system. Massbit will forward traffic through this IP.

Check your public IP address:
``` 
curl ipv4.icanhazip.com
```
### Firewall
Your gateway must open port 443 for https traffic.
You can check if your firewall is open 443 by following step
For example, your IP is 1.2.3.4
* From gateway, open port 443 by netcat in one terminal
``` 
apt install -y netcat
nc -l 443
```
if output is 
```
nc: Address already in use
```
you can check which process is open it 
```
netstat -tunalp |grep -i listen |grep :443
```

* Connect port 443 from public zone from another terminal
```
nc -vz 1.2.3.4 443
```
If output is 
```
Connection to 127.0.0.1 443 port [tcp/https] succeeded!
``` 
then your firewall is open success

Or if output is 
```
nc: connect to 127.0.0.1 port 443 (tcp) failed: Connection refused
```
then you should review your firewall

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
your gateway is success verify

* Check supervisor processses
```
 supervisorctl status
 ```
 output should be
 ```
mbr_gateway                      RUNNING   pid 3469, uptime 62 days, 18:15:07
mbr_gateway_monitor              RUNNING   pid 3029099, uptime 30 days, 18:34:09
```
* Check gateway processses
```
cd /massbit/massbitroute/app/src/sites/services/gateway
./cmd_server status
```
output should be
```
beanstalkd                       RUNNING   pid 3562, uptime 62 days, 18:14:13
monitor_client                   RUNNING   pid 327249, uptime 16 days, 17:12:10
nginx                            RUNNING   pid 1175590, uptime 28 days, 17:57:38
redis                            RUNNING   pid 3561, uptime 62 days, 18:14:13
```
* Check server configure
```
cd /massbit/massbitroute/app/src/sites/services/gateway
./cmd_server nginx -t
```
output should be
```
nginx: the configuration file /massbit/massbitroute/app/src/sites/services/gateway/tmp/nginx.conf syntax is ok
nginx: configuration file /massbit/massbitroute/app/src/sites/services/gateway/tmp/nginx.conf test is successful
```
* Check log debug
```
cd /massbit/massbitroute/app/src/sites/services/gateway
cat logs/debug.log
```

* If your still have problem, just send log for us and ask for help
```
cd /massbit/massbitroute/app/src/sites/services/gateway
./scripts/run _send_log
```

