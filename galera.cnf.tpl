[server]
bind-address="${bind_address}"
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_locks_unsafe_for_binlog=1
query_cache_size=0
query_cache_type=0

[galera]
wsrep_on=ON
wsrep_provider="/usr/lib/galera/libgalera_smm.so"
wsrep_cluster_address="${wsrep_cluster_address}"
wsrep_sst_method=rsync
#wsrep_node_address="{{galera_private_address | default(inventory_hostname) }}"
#wsrep_node_name="{{galera_private_address | default(inventory_hostname) }}"
${galera_conf_section}
