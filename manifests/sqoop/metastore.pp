# == Class: cdh::sqoop::metastore
#
# Installs Sqoop Metastore
#
class cdh::sqoop::metastore {
  Class['cdh::sqoop'] -> Class['cdh::sqoop::metastore']
  package { 'sqoop-metastore':
    ensure => installed
  }
  service { 'sqoop-metastore':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['sqoop-metastore']
  }
}
