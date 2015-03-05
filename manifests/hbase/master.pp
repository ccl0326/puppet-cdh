# == Class: cdh::hbase::master
#
# Installs HBase Master
#
# === Parameters
#
# [*version*]
#   hbase-master package version number
#
# === Examples
#
#  class { 'cdh::hbase::master':
#    version => '0.98.6+cdh5.2.0+55-1.cdh5.2.0.p0.33~precise-cdh5.2.0'
#  }
#
class cdh::hbase::master(
  $version
) {
  # cdh::hbase::master requires HBase package and configs are installed.
  Class['cdh::hbase'] -> Class['cdh::hbase::master']

  package { 'hbase-master':
    ensure => $version
  }
  # sudo -u hdfs hdfs dfs -mkdir /hbase
  # sudo -u hdfs hdfs dfs -chown hbase /hbase
  cdh::hadoop::directory { '/hbase':
    owner => 'hbase'
  }
  service { 'hbase-master':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [Package['hbase-master'], Cdh::Hadoop::Directory['/hbase']]
  }
}
