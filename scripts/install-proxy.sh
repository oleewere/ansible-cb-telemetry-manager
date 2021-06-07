#!/bin/bash

yum install -y squid httpd-tools

export squid_user="squid"
export squid_password="squid"

echo "${squid_password}" > /tmp/plain_assword

htpasswd -c -i /etc/squid/passwords "${squid_user}" < /tmp/plain_assword

rm -rf /tmp/plain_assword

cat <<EOF > /etc/squid/http_whitelist.txt
.cloudera.com
.amazonaws.com
.blob.core.windows.net
.dfs.core.windows.net
EOF

cat <<EOF > /etc/squid/squid.conf
visible_hostname squid
cache deny all

debug_options ALL,2 28,9

# Log format and rotation
logformat squid %ts.%03tu %6tr %>a %Ss/%03>Hs %<st %rm %ru %ssl::bump_mode %ssl::>sni %Sh/%<a %mt
logfile_rotate 10
debug_options rotate=10

http_port 3128
#https_port 3128 cert=/etc/squid/ssl/squid.pem

auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwords
auth_param basic realm proxy
#acl authenticated proxy_auth REQUIRED

acl allowed_http_sites dstdomain "/etc/squid/http_whitelist.txt"
#http_access allow allowed_http_sites authenticated
http_access allow allowed_http_sites
http_access deny all

# Handling HTTP requests
#http_port 3129 intercept

# https://wiki.squid-cache.org/Features/SslPeekAndSplice
# https://wiki.squid-cache.org/ConfigExamples/Intercept/SslBumpExplicit
# Handling HTTPS requests
#https_port 3130 cert=/etc/squid/ssl/squid.pem ssl-bump intercept
#acl SSL_port port 443
#http_access allow SSL_port

#acl ssl_bypass dst 4.4.4.4 # just any ip to define the ACL
# INSERT_SSL_BYPASS_CONF_HERE
#ssl_bump splice ssl_bypass

#acl allowed_https_sites ssl::server_name /etc/squid/https_whitelist.txt
#acl step1 at_step SslBump1
#acl step2 at_step SslBump2
#acl step3 at_step SslBump3
#ssl_bump peek step1 all
#ssl_bump peek step2 allowed_https_sites
#ssl_bump splice step3 allowed_https_sites
#ssl_bump terminate step2 al
EOF

# The Yum installation automatically starts the squid daemon...
# Let's give it a second before we restart it with new config.
# Admittedly, this is probably overkill.
sleep 10
systemctl restart squid