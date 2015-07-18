# == Class: cdh::impala
#
# Installs impala package and configs.
#
# === Parameters
#
# [*state_store_host*]
#   Impala state store server hostname
#
# [*catalog_service_host*]
#   Impala catalog server hostname
#
# [*version*]
#   Impala package version number. Default: installed
#
# === Examples
#
#  class { 'cdh::impala':
#    state_store_host     => 'impala-state-store-node.domain.org',
#    catalog_service_host => 'impala-catalog-node.domain.org'
#  }
#
class cdh::impala(
  $state_store_host,
  $catalog_service_host,
  $version          = $::cdh::impala::defaults::version,
  $default_template = 'cdh/impala/impala.default.erb'
) inherits cdh::impala::defaults {
  Class['cdh::hadoop'] -> Class['cdh::impala']

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

  file { "/etc/default/impala":
    content => template($default_template),
    require => Package['impala']
  }
}
