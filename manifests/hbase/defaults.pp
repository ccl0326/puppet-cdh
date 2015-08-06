# == Class: cdh::hbase::defaults
#
# Default HBase configs
#
class cdh::hbase::defaults {
  $version = 'installed'

  $zookeeper_hosts           = undef
  $zookeeper_znode_parent    = '/hbase'
  $zookeeper_session_timeout = undef

  $hbase_regionserver_codecs       = undef
  $hbase_regionserver_lease_period = undef

  $hbase_client_scanner_caching         = undef
  $hbase_client_scanner_timeout_period  = undef
  $hbase_client_scanner_max_result_size = undef

  $hbase_site_template            = 'cdh/hbase/hbase-site.xml.erb'
  $hadoop_metrics2_hbase_template = 'cdh/hbase/hadoop-metrics2-hbase.properties.erb'
  $hbase_env_template             = 'cdh/hbase/hbase-env.sh.erb'
  $hbase_policy_template          = 'cdh/hbase/hbase-policy.xml.erb'
  $log4j_template                 = 'cdh/hbase/log4j.properties.erb'
}
