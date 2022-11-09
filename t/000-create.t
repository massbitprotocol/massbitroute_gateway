use Test::Nginx::Socket::Lua 'no_plan';

repeat_each(1);

no_shuffle();

# plan tests => blocks() * repeat_each() * 2;
$ENV{TEST_NGINX_HTML_DIR} ||= html_dir();
$ENV{TEST_NGINX_BINARY} =
"/massbit/massbitroute/app/src/sites/services/api/bin/openresty/nginx/sbin/nginx";
our $main_config = <<'_EOC_';
  load_module /massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/nginx/modules/ngx_http_link_func_module.so;
      load_module /massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/nginx/modules/ngx_http_geoip2_module.so;
      load_module /massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/nginx/modules/ngx_stream_geoip2_module.so;
      load_module /massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/nginx/modules/ngx_http_vhost_traffic_status_module.so;
      load_module /massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/nginx/modules/ngx_http_stream_server_traffic_status_module.so;
      load_module /massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/nginx/modules/ngx_stream_server_traffic_status_module.so;

env BIND_ADDRESS;
_EOC_

our $http_config = <<'_EOC_';
   server_tokens off;
    map_hash_max_size 128;
    map_hash_bucket_size 128;
    server_names_hash_bucket_size 128;
    include /massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/nginx/conf/mime.types;
    access_log /massbit/massbitroute/app/src/sites/services/gateway/logs/nginx/nginx-access.log;
    # tmp
    client_body_temp_path /massbit/massbitroute/app/src/sites/services/gateway/tmp/client_body_temp;
    fastcgi_temp_path /massbit/massbitroute/app/src/sites/services/gateway/tmp/fastcgi_temp;
    proxy_temp_path /massbit/massbitroute/app/src/sites/services/gateway/tmp/proxy_temp;
    scgi_temp_path /massbit/massbitroute/app/src/sites/services/gateway/tmp/scgi_temp;
    uwsgi_temp_path /massbit/massbitroute/app/src/sites/services/gateway/tmp/uwsgi_temp;
    lua_package_path '/massbit/massbitroute/app/src/sites/services/gateway/gbc/src/?.lua;/massbit/massbitroute/app/src/sites/services/gateway/lib/?.lua;/massbit/massbitroute/app/src/sites/services/gateway/src/?.lua;/massbit/massbitroute/app/src/sites/services/gateway/sites/../src/?.lua/massbit/massbitroute/app/src/sites/services/gateway/sites/../lib/?.lua;/massbit/massbitroute/app/src/sites/services/gateway/sites/../src/?.lua;/massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/site/lualib/?.lua;;';
    lua_package_cpath '/massbit/massbitroute/app/src/sites/services/gateway/gbc/src/?.so;/massbit/massbitroute/app/src/sites/services/gateway/lib/?.so;/massbit/massbitroute/app/src/sites/services/gateway/src/?.so;/massbit/massbitroute/app/src/sites/services/gateway/sites/../src/?.so/massbit/massbitroute/app/src/sites/services/gateway/sites/../lib/?.so;/massbit/massbitroute/app/src/sites/services/gateway/sites/../src/?.so;/massbit/massbitroute/app/src/sites/services/gateway/bin/openresty/site/lualib/?.so;;';
            resolver 8.8.8.8 ipv6=off;
            variables_hash_bucket_size 512;
            server_names_hash_max_size 1024;
            #ssl
            lua_shared_dict auto_ssl 1m;
            lua_shared_dict auto_ssl_settings 64k;

            #lua
            lua_capture_error_log 32m;
            #lua_need_request_body on;
            lua_regex_match_limit 1500;
            lua_check_client_abort on;
            lua_socket_log_errors off;
            lua_shared_dict _GBC_ 1024k;
            lua_code_cache on;
        

#_INCLUDE_SITES_HTTPINIT_
    init_by_lua '\n    
	   require("framework.init")
	   local appKeys = dofile("/massbit/massbitroute/app/src/sites/services/gateway/tmp/app_keys.lua")
	   local globalConfig = dofile("/massbit/massbitroute/app/src/sites/services/gateway/tmp/config.lua")
	   cc.DEBUG = globalConfig.DEBUG
	   local gbc = cc.import("#gbc")
	   cc.exports.nginxBootstrap = gbc.NginxBootstrap:new(appKeys, globalConfig)
        

--_INCLUDE_SITES_LUAINIT_\n    ';
    init_worker_by_lua '\n    

        

--_INCLUDE_SITES_LUAWINIT_\n    ';

map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
vhost_traffic_status_zone shared:vhost_traffic_status:32m;
vhost_traffic_status_dump /massbit/massbitroute/app/src/sites/services/gateway/data/vts_gw.db;
log_format main_json escape=json '{' '"msec": "$msec", ' '"connection": "$connection", ' '"connection_requests": "$connection_requests", ' '"pid": "$pid", ' '"request_id": "$request_id", ' '"request_length": "$request_length", ' '"remote_addr": "$remote_addr", ' '"remote_user": "$remote_user", ' '"remote_port": "$remote_port", ' '"time_local": "$time_local", ' '"time_iso8601": "$time_iso8601", ' '"request": "$request", ' '"request_uri": "$request_uri", ' '"args": "$args", ' '"status": "$status", ' '"body_bytes_sent": "$body_bytes_sent", ' '"bytes_sent": "$bytes_sent", ' '"http_referer": "$http_referer", ' '"http_user_agent": "$http_user_agent", ' '"http_x_forwarded_for": "$http_x_forwarded_for", ' '"http_host": "$http_host", ' '"server_name": "$server_name", ' '"request_time": "$request_time", ' '"upstream": "$upstream_addr", ' '"upstream_connect_time": "$upstream_connect_time", ' '"upstream_header_time": "$upstream_header_time", ' '"upstream_response_time": "$upstream_response_time", ' '"upstream_response_length": "$upstream_response_length", ' '"upstream_cache_status": "$upstream_cache_status", ' '"ssl_protocol": "$ssl_protocol", ' '"ssl_cipher": "$ssl_cipher", ' '"scheme": "$scheme", ' '"request_method": "$request_method", ' '"server_protocol": "$server_protocol", ' '"pipe": "$pipe", ' '"gzip_ratio": "$gzip_ratio", ' '"request_body": "$request_body", ' '"http_cf_ray": "$http_cf_ray", ' '"real_ip": "$http_x_forwarded_for",' '"tcpinfo_rtt": "$tcpinfo_rtt",' '"tcpinfo_rttvar": "$tcpinfo_rttvar"' '}';
include /massbit/massbitroute/app/src/sites/services/gateway/sites/../etc/_geoip.conf;
include /massbit/massbitroute/app/src/sites/services/gateway/sites/../http.d/*.conf0;
include /massbit/massbitroute/app/src/sites/services/gateway/sites/../http.d/*.conf9;

_EOC_

our $config = <<'_EOC_';
 location /_rtt {
        echo $tcpinfo_rtt;
    }
    location /_ping {
        return 200 pong;
    }
    location /__data {
        autoindex on;
        alias /massbit/massbitroute/app/src/sites/services/gateway/data;
    }
    location /__log {
        autoindex on;
        alias /massbit/massbitroute/app/src/sites/services/gateway/logs;
    }
    location /__vars {
        autoindex on;
        alias /massbit/massbitroute/app/src/sites/services/gateway/vars;
    }
    location /__conf {
        autoindex on;
        alias /massbit/massbitroute/app/src/sites/services/gateway/http.d;
    }
    location /__worker/ {
        proxy_pass http://127.0.0.1:4040/;
    }
    location /__internal_status_vhost/ {
        include /massbit/massbitroute/app/src/sites/services/gateway/etc/_vts_server.conf;
    }
    # location /__cmd {
    #     default_type application/json;
    #     content_by_lua_file /massbit/massbitroute/app/src/sites/services/gateway/src/cmd.lua;
    # }
    include /massbit/massbitroute/app/src/sites/services/gateway/etc/_test_server.conf;

_EOC_
run_tests();

__DATA__

=== Api create new

--- main_config eval: $::main_config
--- http_config eval: $::http_config
--- config eval: $::config
--- request
GET /_rtt
--- error_code: 200
--- no_error_log
