# == Class: cdh::impala
#
# Installs impala and impala-shell packages and configs.
# All other impala classes require this one.
#
# Please make sure you set
#
#   short_circuit_reads_enabled     => true,
#   block_location_tracking_enabled => true
#
# when you include cdh::hadoop. If you don't, Impala won't work!
#
# === Parameters
#
# [*master_host*]
#   Hostname where Impala master daemons are running
#
# [*version*]
#   Impala package version number. Default: installed
#
# === Examples
#
#  class { 'cdh::impala':
#    master_host => 'impala-state-store-node.domain.org',
#    version     => '2.2.0+cdh5.4.2+0-1.cdh5.4.2.p0.4~wheezy-cdh5.4.2'
#  }
#
class cdh::impala(
  $master_host,
  $version          = $::cdh::impala::defaults::version,
  $default_template = 'cdh/impala/impala.default.erb'
) inherits cdh::impala::defaults {
  Class['cdh::hadoop'] -> Class['cdh::impala']
  Class['cdh::hive'] -> Class['cdh::impala']

  package { ['impala', 'impala-shell']:
    ensure => $version
  }

  $config_directory = "/etc/impala/conf.${cdh::hadoop::cluster_name}"
  # Create the $cluster_name based $config_directory.
  file { $config_directory:
    ensure  => 'directory',
    require => Package['impala']
  }
  cdh::alternative { 'impala-conf':
    link    => '/etc/impala/conf',
    path    => $config_directory,
    require => File[$config_directory]
  }

  file { "${config_directory}/core-site.xml":
    ensure  => 'link',
    target  => "/etc/hadoop/conf/core-site.xml",
    require => File[$config_directory]
  }
  file { "${config_directory}/hdfs-site.xml":
    ensure  => 'link',
    target  => "/etc/hadoop/conf/hdfs-site.xml",
    require => File[$config_directory]
  }
  file { "${config_directory}/hbase-site.xml":
    ensure  => 'link',
    target  => "/etc/hbase/conf/hbase-site.xml",
    require => File[$config_directory]
  }
  file { "${config_directory}/hive-site.xml":
    ensure  => 'link',
    target  => "/etc/hive/conf/hive-site.xml",
    require => File[$config_directory]
  }

  $fair_scheduler_enabled = $::cdh::hadoop::fair_scheduler_enabled
  file { "/etc/default/impala":
    content => template($default_template),
    require => Package['impala']
  }
}
