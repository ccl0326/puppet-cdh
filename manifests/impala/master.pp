# == Class: cdh::impala::master
#
# Installs impala master services.
# This assumes you want to run state-store, catalog, and llama on the same node.
#
# === Examples
#
#  include cdh::impala::master
#
class cdh::impala::master {
  # cdh::impala::master requires Impala package and configs are installed.
  Class['cdh::impala'] -> Class['cdh::impala::master']

  include cdh::impala::defaults
  package { ['impala-state-store', 'impala-catalog', 'llama-master']:
    ensure => $cdh::impala::defaults::version
  }
  service { 'impala-state-store':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['impala-state-store']
  }
  service { 'impala-catalog':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['impala-catalog']
  }
  service { 'llama':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['llama-master']
  }
}
