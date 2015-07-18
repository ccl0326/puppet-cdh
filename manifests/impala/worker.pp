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

  package { 'impala-server':
    ensure => $cdh::impala::defaults::version
  }

  # Installing cgroup-bin to have cgroups mounted in /sys/fs/cgroup
  # and allow us to use cgcreate to create a CPU cgroup for Impala.
  package { 'cgroup-bin':
    ensure => 'installed'
  }
  exec { 'cgroup-create-impala':
    command => '/usr/bin/cgcreate -a impala:impala -t impala:impala -g cpu:impala',
    creates => "${cdh::impala::defaults::cgroup_path}/tasks",
    require => [Package['impala-server'], Package['cgroup-bin']]
  }

  service { 'impala-server':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
      Package['impala-server'],
      Exec['cgroup-create-impala']
    ]
  }
}
