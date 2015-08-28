# == Class: cdh::impala::defaults
#
# Default Impala configs
#
class cdh::impala::defaults {
  $version              = 'installed'
  $num_cores            = 0
  $mem_limit            = '16G'
  $idle_query_timeout   = 0
  $idle_session_timeout = 0
  $enable_rm            = true

  # Impala uses cgroups to manage resources.
  # Create a cgroup mount in which to Impala will manage its CPU cgroups.
  $cgroup_path = '/sys/fs/cgroup/impala'
}
