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
# [*zookeeper_hosts*]
#   Array of ZooKeeper hostname/IP(:port)s. Default: undef (HBase will run
#   in pseudo-distributed mode)
#
# [*hbase_site_template*]
#   hbase-site.xml template path
#
# === Examples
#
#  class { 'cdh::hbase':
#    namenode_host   => 'namenode.domain.org',
#    zookeeper_hosts => [
#      'zk1.domain.org',
#      'zk2.domain.org',
#      'zk3.domain.org'
#    ]
#  }
#
class cdh::hbase(
  $namenode_host,
  $zookeeper_hosts     = $cdh::hbase::defaults::zookeeper_hosts,
  $hbase_site_template = $cdh::hbase::defaults::hbase_site_template
) inherits cdh::hbase::defaults {
  Class['cdh::hadoop'] -> Class['cdh::hbase']

  package { 'hbase':
    ensure => 'installed'
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
}
