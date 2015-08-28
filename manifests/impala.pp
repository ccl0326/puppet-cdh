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
# [*num_cores*]
#   If > 0, it sets the number of cores available to Impala. Setting it to 0 means
#   Impala will use all available cores on the machine according to
#   /proc/cpuinfo. Default: 0
#
# [*mem_limit*]
#   Limit the amount of memory available to Impala. You can specify the memory limit
#   using absolute notation such as 500m or 2G, or as a percentage of physical memory
#   such as 60%. Default: 16G
#
# [*idle_query_timeout*]
#   The time, in seconds, that a query may be idle for (i.e. no processing work is
#   done and no updates are received from the client) before it is cancelled.
#   If 0, idle queries are never expired. Default: 0
#
# [*idle_session_timeout*]
#   The time, in seconds, that a session may be idle for before it is closed (and
#   all running queries cancelled) by Impala. If 0, idle sessions are never
#   expired. Default: 0
#
# [*enable_rm*]
#   Whether to enable resource management or not. Default: true
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
  $version              = $::cdh::impala::defaults::version,
  $num_cores            = $::cdh::impala::defaults::num_cores,
  $mem_limit            = $::cdh::impala::defaults::mem_limit,
  $idle_query_timeout   = $::cdh::impala::defaults::idle_query_timeout,
  $idle_session_timeout = $::cdh::impala::defaults::idle_session_timeout,
  $enable_rm            = $::cdh::impala::defaults::enable_rm,
  $default_template     = 'cdh/impala/impala.default.erb'
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
