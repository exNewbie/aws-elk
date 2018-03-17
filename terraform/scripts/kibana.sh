#!/bin/bash -xe
printf ${ProxyUsername}:`openssl passwd -apr1 ${ProxyPass}` >> /etc/nginx/conf.d/kibana.htpasswd
# Remove the default location from nginx config
sed -ri '/location \//,/.*\}/d' /etc/nginx/nginx.conf
service nginx restart
