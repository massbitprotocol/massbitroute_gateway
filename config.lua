local _config = {
    server = {
        nginx = {
            port = "80",
            port_ssl = "443",
            server_name = "massbitroute"
        }
    },
    templates = {},
    apps = {},
    supervisors = {
        ["monitor_client"] = [[
[program:monitor_client]
command=/bin/bash _SITE_ROOT_/../mkagent/agents/push.sh _SITE_ROOT_
autorestart=true
redirect_stderr=true
stopasgroup=true
killasgroup=true
stopsignal=INT
stdout_logfile=_SITE_ROOT_/../mkagent/logs/monitor_client.log
    ]]
    },
    supervisor = [[
]],
    supervisor1 = [[
[program:fisherman]
command=/bin/bash _SITE_ROOT_/services/fisherman/run.sh _SITE_ROOT_
autorestart=true
redirect_stderr=true
stopasgroup=true
killasgroup=true
stopsignal=INT
stdout_logfile=_SITE_ROOT_/logs/fisherman.log
]]
}
return _config
