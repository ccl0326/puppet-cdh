# == Class: cdh::sqoop::defaults
#
# Default parameters for cdh::sqoop configuration.
#
class cdh::sqoop::defaults {
    $hadoop_opts                            = undef
    $sqoop_metastore_client_autoconnect_url = undef
    $sqoop_metastore_client_record_password = true
}
