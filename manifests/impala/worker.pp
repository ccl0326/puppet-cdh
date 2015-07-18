# == Class: cdh::impala::worker
#
# Installs and runs impalad server.
# You should probably include this on all your Hadoop worker nodes
#
# === Examples
#
#  include cdh::impala::worker
#
class cdh::impala::worker {
  # cdh::impala::worker requires Impala package and configs are installed.
  Class['cdh::impala'] -> Class['cdh::impala::worker']

  include cdh::impala::defaults

  # Create a path in which to store CGroups for Impala.
  file { "$cdh::impala::defaults::cgroup_path":
    ensure  => 'directory',
    owner   => 'impala',
    group   => 'impala',
    require => Package['impala-server']
  }

  package { 'impala-server':
    ensure => $cdh::impala::defaults::version
  }
  service { 'impala-server':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
      Package['impala-server'],
      File["$cdh::impala::defaults::cgroup_path"]
    ]
  }
}
