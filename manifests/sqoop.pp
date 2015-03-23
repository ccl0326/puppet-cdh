# == Class: cdh::sqoop
#
# Installs Sqoop 1
#
class cdh::sqoop(
    $hadoop_opts = $::cdh::sqoop::defaults::hadoop_opts
) {
    # Sqoop requires Hadoop configs installed.
    Class['cdh::hadoop'] -> Class['cdh::sqoop']

    package { 'sqoop':
        ensure => 'installed',
    }

    if (!defined(Package['libmysql-java'])) {
        package { 'libmysql-java':
            ensure => 'installed',
        }
    }
    # symlink the mysql-connector-java.jar that is installed by
    # libmysql-java into /usr/lib/sqoop/lib
    # TODO: Can I create this symlink as mysql.jar?
    file { '/usr/lib/sqoop/lib/mysql-connector-java.jar':
        ensure  => 'link',
        target  => '/usr/share/java/mysql-connector-java.jar',
        require => [Package['sqoop'], Package['libmysql-java']],
    }

    $config_directory = "/etc/sqoop/conf.${cdh::hadoop::cluster_name}"
    # Create the $cluster_name based $config_directory.
    file { $config_directory:
        ensure  => 'directory',
        require => Package['sqoop']
    }
    cdh::alternative { 'sqoop-conf':
        link    => '/etc/sqoop/conf',
        path    => $config_directory,
        require => File[$config_directory]
    }

    file { "${config_directory}/sqoop-env.sh":
        content => template('cdh/sqoop/sqoop-env.sh.erb'),
        require => [Package['sqoop'], File[$config_directory]]
    }
}
