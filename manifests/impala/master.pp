# == Class: cdh::impala::master
#
# Installs impala-state-store and impala-catalog.
#
# === Examples
#
#  include cdh::impala::master
#
class cdh::impala::master {
  # cdh::impala::master requires Impala package and configs are installed.
  Class['cdh::impala'] -> Class['cdh::impala::master']

  include cdh::impala::defaults
  package { ['impala-state-store', 'impala-catalog']:
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
}
