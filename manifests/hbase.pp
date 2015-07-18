# == Class: cdh::hbase
#
# Installs hbase package and configs.
# Use this in conjunction with cdh::hbase::master to install and set up a
# HBase Master.
#
# === Parameters
#
# [*namenode_host*]
#   NameNode hostname
#
# [*version*]
#   hbase package version number. Default: installed
#
# [*zookeeper_hosts*]
#   Array of ZooKeeper hostname/IP(:port)s. Default: undef (HBase will run
#   in pseudo-distributed mode)
#
# [*zookeeper_znode_parent*]
#   Root ZNode for HBase in ZooKeeper. Default: /hbase
#
# [*zookeeper_session_timeout*]
#   ZooKeeper session timeout in milliseconds. Default: undef
#
# [*hbase_regionserver_codecs*]
#   compression codecs check
#
# [*hbase_site_template*]
#   hbase-site.xml template path
#
# [*hadoop_metrics2_hbase_template*]
#   hadoop-metrics2-hbase.properties template path
#
# [*hbase_env_template*]
#   hbase-env.sh template path
#
# [*hbase_policy_template*]
#   hbase-policy.xml template path
#
# [*log4j_template*]
#   log4j.properties template path
#
# === Examples
#
#  class { 'cdh::hbase':
#    version                   => '0.98.6+cdh5.2.0+55-1.cdh5.2.0.p0.33~precise-cdh5.2.0',
#    namenode_host             => 'namenode.domain.org',
#    zookeeper_hosts           => [
#      'zk1.domain.org',
#      'zk2.domain.org',
#      'zk3.domain.org'
#    ],
#    hbase_regionserver_codecs => ['snappy']
#  }
#
class cdh::hbase(
  $namenode_host,
  $version                        = $::cdh::hbase::defaults::version,
  $zookeeper_hosts                = $::cdh::hbase::defaults::zookeeper_hosts,
  $zookeeper_znode_parent         = $::cdh::hbase::defaults::zookeeper_znode_parent,
  $zookeeper_session_timeout      = $::cdh::hbase::defaults::zookeeper_session_timeout,
  $hbase_regionserver_codecs      = $::cdh::hbase::defaults::hbase_regionserver_codecs,
  $hbase_site_template            = $::cdh::hbase::defaults::hbase_site_template,
  $hadoop_metrics2_hbase_template = $::cdh::hbase::defaults::hadoop_metrics2_hbase_template,
  $hbase_env_template             = $::cdh::hbase::defaults::hbase_env_template,
  $hbase_policy_template          = $::cdh::hbase::defaults::hbase_policy_template,
  $log4j_template                 = $::cdh::hbase::defaults::log4j_template
) inherits cdh::hbase::defaults {
  Class['cdh::hadoop'] -> Class['cdh::hbase']

  package { 'hbase':
    ensure => $version
  }

  $config_directory = "/etc/hbase/conf.${cdh::hadoop::cluster_name}"
  # Create the $cluster_name based $config_directory.
  file { $config_directory:
    ensure  => 'directory',
    require => Package['hbase']
  }
  cdh::alternative { 'hbase-conf':
    link    => '/etc/hbase/conf',
    path    => $config_directory,
    require => File[$config_directory]
  }

  file { "${config_directory}/hbase-site.xml":
    content => template($hbase_site_template),
    owner   => 'hbase',
    group   => 'hbase',
    require => [Package['hbase'], File[$config_directory]]
  }
  file { "${config_directory}/hadoop-metrics2-hbase.properties":
    content => template($hadoop_metrics2_hbase_template),
    owner   => 'hbase',
    group   => 'hbase',
    require => [Package['hbase'], File[$config_directory]]
  }
  file { "${config_directory}/hbase-env.sh":
    content => template($hbase_env_template),
    owner   => 'hbase',
    group   => 'hbase',
    require => [Package['hbase'], File[$config_directory]]
  }
  file { "${config_directory}/hbase-policy.xml":
    content => template($hbase_policy_template),
    owner   => 'hbase',
    group   => 'hbase',
    require => [Package['hbase'], File[$config_directory]]
  }
  file { "${config_directory}/log4j.properties":
    content => template($log4j_template),
    owner   => 'hbase',
    group   => 'hbase',
    require => [Package['hbase'], File[$config_directory]]
  }
}
