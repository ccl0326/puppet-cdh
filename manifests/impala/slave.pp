# == Class: cdh::impala::slave
#
# Installs impala-server.
#
# === Examples
#
#  include cdh::impala::slave
#
class cdh::impala::slave {
  # cdh::impala::slave requires Impala package and configs are installed.
  Class['cdh::impala'] -> Class['cdh::impala::slave']

  include cdh::impala::defaults
  package { 'impala-server':
    ensure => $cdh::impala::defaults::version
  }
  service { 'impala-server':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['impala-server']
  }
}
