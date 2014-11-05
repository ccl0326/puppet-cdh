# == Class: cdh::hbase::defaults
#
# Default HBase configs
#
class cdh::hbase::defaults {
  $zookeeper_hosts     = undef
  $hbase_site_template = 'cdh/hbase/hbase-site.xml.erb'
}
