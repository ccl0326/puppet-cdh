# == Class: cdh::impala::defaults
#
# Default Impala configs
#
class cdh::impala::defaults {
  $version = 'installed'

  # Impala uses cgroups to manage resources.
  # Create a cgroup mount in which to Impala will manage its CPU cgroups.
  $cgroup_path = '/sys/fs/cgroup/impala'
}
