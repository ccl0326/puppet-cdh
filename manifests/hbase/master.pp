# == Class: cdh::hbase::master
#
# Installs HBase Master
#
# === Examples
#
#  include cdh::hbase::master
#
class cdh::hbase::master() {
  # cdh::hbase::master requires HBase package and configs are installed.
  Class['cdh::hbase'] -> Class['cdh::hbase::master']

  package { 'hbase-master':
    ensure => 'installed'
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
