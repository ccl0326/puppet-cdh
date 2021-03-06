# == Class: cdh::hbase::slave
#
# Installs HBase RegionServer and Thrift server
#
# === Parameters
#
# [*version*]
#   hbase-regionserver and hbase-thrift package version number. Default: installed
#
# === Examples
#
#  class { 'cdh::hbase::slave':
#    version => '0.98.6+cdh5.2.0+55-1.cdh5.2.0.p0.33~precise-cdh5.2.0'
#  }
#
class cdh::hbase::slave(
  $version = $cdh::hbase::defaults::version
) {
  # cdh::hbase::slave requires HBase package and configs are installed.
  Class['cdh::hbase'] -> Class['cdh::hbase::slave']

  package { 'hbase-regionserver':
    ensure => $version
  }
  service { 'hbase-regionserver':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['hbase-regionserver']
  }

  package { 'hbase-thrift':
    ensure => $version
  }
  service { 'hbase-thrift':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['hbase-thrift']
  }
}
