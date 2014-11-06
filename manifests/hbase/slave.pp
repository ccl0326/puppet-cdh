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
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['hbase-regionserver']
  }

  package { 'hbase-thrift':
    ensure => 'installed'
  }
}
