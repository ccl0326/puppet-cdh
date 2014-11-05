# == Class: cdh::hbase::slave
#
# Installs HBase RegionServer and Thrift server
#
# === Examples
#
#  include cdh::hbase::slave
#
class cdh::hbase::slave() {
  # cdh::hbase::slave requires HBase package and configs are installed.
  Class['cdh::hbase'] -> Class['cdh::hbase::slave']

  package { 'hbase-regionserver':
    ensure => 'installed'
  }
  service { 'hbase-regionserver':
    ensure     => 'running',
    require    => Package['hbase-regionserver'],
    hasrestart => true,
    hasstatus  => true
  }

  package { 'hbase-thrift':
    ensure => 'installed'
  }
}
