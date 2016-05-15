#!/bin/bash

set -e
set -u

: ${bind_address:="0.0.0.0"}

if [[ -v galera_cluster_members ]]
then
  wsrep_cluster_address="gcomm://${galera_cluster_members}"
elif [[ ! -v wsrep_cluster_address ]]
then
  echo "Need to set galera_cluster_members or wsrep_cluster_address variables"
  exit 1
fi

galera_conf_section=""
[[ -v wsrep_node_address ]] && \
  galera_conf_section+="wsrep_node_address=${wsrep_node_address}\n"
[[ -v wsrep_node_name ]] && \
  galera_conf_section+="wsrep_node_name=${wsrep_node_name}\n"

if [[ -v ssl_cert_pem ]]
then
  echo "$ssl_cert_pem" > /galera/ssl/ssl_cert.pem
fi
if [[ -v ssl_key_pem ]]
then
  echo "$ssl_key_pem" > /galera/ssl/ssl_key.pem
fi

if [[ (-f /galera/ssl/ssl_cert.pem) && (! -f /galera/ssl/ssl_key.pem) || ( (-f /galera/ssl/ssl_key.pem) && (! -f /galera/ssl/ssl_cert.pem) ) ]]
then
  echo "Both (or none) of /galera/ssl/ssl_{cert,key}.pem must be given"
  exit 2
elif [[ -f /galera/ssl/ssl_cert.pem ]]
then
  galera_conf_section+='wsrep_provider_options="socket.ssl_cert=/galera/ssl/cert.pem;socket.ssl_key=/galera/ssl/key.pem"'
fi

eval "cat >> /etc/mysql/conf.d/galera.cnf << EOF
$(cat /galera/galera.cnf.tpl)
EOF"

if [[ -v mariadb_display_configuration ]] 
then
  echo '--BEGIN----------/etc/mysql/conf.d/galera.cnf-----------------'
  cat /etc/mysql/conf.d/galera.cnf
  echo '--END------------/etc/mysql/conf.d/galera.cnf-----------------'
fi

/docker-entrypoint.sh $@

