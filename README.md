# Description

Puppet module to install and manage components of
Cloudera's Distribution (CDH) for Apache Hadoop.

This repository works with CDH5.  For CDH4, use the ```cdh4``` branch.

NOTE: The main puppet-cdh repository is hosted in WMF Gerrit at
[operations/puppet/cdh](https://gerrit.wikimedia.org/r/#/admin/projects/operations/puppet/cdh).


Installs HDFS, YARN, Hive, Impala, Pig, Sqoop (1), Oozie,
Hue and HBase.  Note that, in order for this module to work, you will have to ensure
that:

- Java version 7 or greater is installed
- Your package manager is configured with a repository containing the
  Cloudera 5 packages.

**Notes:**

- In general, services managed by this module do not subscribe to their relevant
  config files.  This prevents accidental deployments of config changes.  If you
  make config changes in puppet, you must apply puppet and then manually restart
  the relevant services.
- This module has only been tested using CDH 5.0.1 on Ubuntu Precise 12.04.2 LTS
- ZooKeeper is not puppetized in this module, as Debian/Ubuntu provides
  a different and suitable ZooKeeper package.  To puppetize ZooKeeper Servers,
  See the [puppet-zookeeper](https://github.com/wikimedia/puppet-zookeeper) module.


# Installation

Update your `Puppetfile` with these lines:

```
mod "cdh",
  :git => "https://github.com/zhihu/puppet-cdh.git"
```


# Hadoop

## Hadoop Clients

All Hadoop enabled nodes should include the ```cdh::hadoop``` class.

```puppet
class my::hadoop {
  class { 'cdh::hadoop':
    # Logical Hadoop cluster name.
    cluster_name      => 'mycluster',
    # Set to false if you doesn't need setup MapReduce (YARN or MRv1), i.e. only HDFS installed.
    mapreduce_enabled => true,
    # Must pass an array of hosts here, even if you are
    # not using HA and only have a single NameNode.
    namenode_hosts    => ['namenode1.domain.org'],
    datanode_mounts   => [
      '/var/lib/hadoop/data/a',
      '/var/lib/hadoop/data/b',
      '/var/lib/hadoop/data/c'
    ],
    # You can also provide an array of dfs_name_dirs.
    dfs_name_dir      => '/var/lib/hadoop/name',
  }
}

node 'hadoop-client.domain.org' {
  include my::hadoop
}
```

This will ensure that CDH5 client packages are installed, and that
Hadoop related config files are in place with proper settings.

The `datanode_mounts` parameter assumes that you want to keep your
DataNode and YARN specific data in subdirectories in each of the mount
points provided.

## Hadoop Master

```puppet
class my::hadoop::master inherits my::hadoop {
  include cdh::hadoop::master
}

node 'namenode1.domain.org' {
  include my::hadoop::master
}
```

This installs and starts up the NameNode.  If using YARN this will install
and set up ResourceManager and HistoryServer.  If using MRv1, this will install
and set up the JobTracker.

## Hadoop Workers

```puppet
class my::hadoop::worker inherits my::hadoop {
  include cdh::hadoop::worker
}

node 'datanode[1234].domain.org' {
  include my::hadoop::worker
}
```

This installs and starts up the DataNode.  If using YARN, this will install
and set up the NodeManager.  If using MRv1, this will install and set up the
TaskTracker.

## High Availability NameNode

For detailed documentation, see the
[CDH5 High Availability Guide](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-High-Availability-Guide/cdh5hag_hdfs_ha_config.html).

This puppet module only supports Quorum-based HA storage using JournalNodes.
It does not support NFS based HA.

Your JournalNodes will be automatically configured based on the value of
```$cdh::hadoop::journalnode_hosts```.  When ```cdh::hadoop``` is included,
if the current hostname or IP address matches a value in the $journalnode_hosts
array, then ```cdh::hadoop::journalnode``` will be included.

Before applying ```cdh::hadoop::journalnode```, make sure the
```dfs_journalnode_edits_dir``` is partitioned and mounted on each of the hosts
in ```journalnode_hosts```.

When setting up a new cluster, you should ensure that your JournalNodes are up
and running before your NameNodes.  When the NameNode is formatted for the first
time, it will talk to the JournalNodes and tell them to initialize their shared
edits directories.  If you are adding HA to an existing cluster, you will need
to initialize your JournalNodes manually.  See section below on how to do this.

You'll need to set two extra parameters on the ```cdh::hadoop``` class on all
your hadoop nodes, as well as specify the hosts of your standby NameNodes.

```puppet
class my::hadoop {
  class { 'cdh::hadoop':
    cluster_name      => 'mycluster',
    namenode_hosts    => [
      'namenode1.domain.org',
      'namenode2.domain.org'
    ],
    journalnode_hosts => [
      'datanode1.domain.org',
      'datanode2.domain.org',
      'datanode3.domain.org'
    ],
    datanode_mounts   => [
      '/var/lib/hadoop/data/a',
      '/var/lib/hadoop/data/b',
      '/var/lib/hadoop/data/c'
    ],
    dfs_name_dir      => ['/var/lib/hadoop/name', '/mnt/hadoop_name'],
  }
}

node 'hadoop-client.domain.org' {
  include my::hadoop
}
```

Note the differences from the non-HA setup:

- Multiple ```namenode_hosts``` have been given.  You will need to include
```cdh::hadoop::namenode::standby``` on your standby NameNodes.
- ```journalnode_hosts``` have been specified.

On your standby NameNodes, instead of including ```cdh::hadoop::master```,
include ```cdh::hadoop::namenode::standby```:

``` puppet
class my::hadoop::master inherits my::hadoop {
  include cdh::hadoop::master
}
class my::hadoop::standby inherits my::hadoop {
  include cdh::hadoop::namenode::standby
}

node 'namenode1.domain.org' {
  include my::hadoop::master
}

node 'namenode2.domain.org' {
  include my::hadoop::standby
}
```

Including ```cdh::hadoop::namenode::standby``` will bootstrap the standby
NameNode from the primary NameNode and start the standby NameNode service.

When are setting up brand new Hadoop cluster with HA, you should apply your
puppet manifests to nodes in this order:

1. JournalNodes
2. Primary Hadoop master node (active NameNode)
3. StandBy NameNodes
4. Worker nodes (DataNodes)

### Adding High Availability to a running cluster

Go through all of the same steps as described in the above section.  Once all
of your puppet manifests have been applied (JournalNodes running, NameNodes running and
formatted/bootstrapped, etc.) you can initialize your
JournalNodes' shared edit directories.

```bash
# Shutdown your HDFS cluster.  Everything will need a
# restart on order to load the newly applied HA configs.
# (Leave the JournalNodes running.)

# On your hadoop master node:
sudo service hadoop-yarn-resourcemanager stop
sudo service hadoop-hdfs-namenode stop

# On your hadoop worker nodes:
sudo service hadoop-hdfs-datanode stop
sudo service hadoop-yarn-nodemanager stop


# Now run the following commands on your primary active NameNode.

# initialize the JournalNodes' shared edit directories:
sudo -u hdfs /usr/bin/hdfs namenode -initializeSharedEdits

# Now restart your Hadoop master services

# On your hadoop master node:
sudo service hadoop-hdfs-namenode start
sudo service hadoop-yarn-resourcemanager start

# Now that your primary NameNode is back up, and
# JournalNodes have been initialized, bootstrap
# your Standby NameNode(s).  Run this command
# on your standby NameNode(s):
sudo -u hdfs /usr/bin/hdfs namenode -bootstrapStandby

# On your hadoop worker nodes:
sudo service hadoop-yarn-nodemanager start
sudo service hadoop-hdfs-datanode start
```

When there are multiple NameNodes and automatic failover is not configured
(it is not yet supported by this puppet module), both NameNodes start up
in standby mode.  You will have to manually transition one of them to active.

```bash
# on your hadoop master node:
sudo -u hdfs /usr/bin/hdfs haadmin -transitionToActive <namenode_id>
```

```<namenode_id>``` will be the first entry in the ```$namenode_hosts``` array,
with dot ('.') characters replaced with dashes ('-').  E.g.  ```namenode1-domain-org```.


# Hive

## Hive Clients

```puppet
class { 'cdh::hive':
  metastore_host  => 'hive-metastore-node.domain.org',
  zookeeper_hosts => ['zk1.domain.org', 'zk2.domain.org'],
  jdbc_password   => $secret_password
}
```

## Hive Master (hive-server2 and hive-metastore)

Include the same ```cdh::hive``` class as indicated above, and then:

```puppet
include cdh::hive::master
```

By default, a Hive metastore backend MySQL database will be used.  You must
separately ensure that your $metastore_database (e.g. mysql) package is installed.
If you want to disable automatic setup of your metastore backend
database, set the ```metastore_database``` parameter to undef:

```puppet
class { 'cdh::hive::master':
  metastore_database => undef
}
```


# Impala

## Requirement

You need enable HDFS [short-circuit local
reads](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/ShortCircuitLocalReads.html) and [block location tracking](http://www.cloudera.com/content/cloudera/en/documentation/cloudera-impala/latest/topics/impala_config_performance.html?scroll=config_performance__block_location_tracking) first.

```puppet
class { 'cdh::hadoop':
  ...
  short_circuit_reads_enabled     => true,
  block_location_tracking_enabled => true,
  ...
}
```

Then restart all DataNodes.

## Impala Master

This assumes you want to run state-store, catalog, and llama on the same node.

```puppet
class { 'cdh::impala':
  master_host => 'impala-master-node.domain.org',
  version     => '2.2.0+cdh5.4.2+0-1.cdh5.4.2.p0.4~wheezy-cdh5.4.2'
}
include cdh::impala::master
```

## Impala Workers (impala-server)

```puppet
class { 'cdh::impala':
  master_host => 'impala-master-node.domain.org',
  version     => '2.2.0+cdh5.4.2+0-1.cdh5.4.2.p0.4~wheezy-cdh5.4.2'
}
include cdh::impala::worker
```


# Oozie

## Oozie Clients

```puppet
include cdh::oozie
```

## Oozie Server

The following will install and run oozie-server, as well as create a MySQL
database for it to use. A MySQL database is the only currently supported
automatically installable backend database.  Alternatively, you may set
```database => undef``` to avoid setting up MySQL and then configure your own
Oozie database manually.

```puppet
class { 'cdh::oozie::server:
  jdbc_password -> $secret_password
}
```


# Hue

To install Hue server, simply:

```puppet
class { 'cdh::hue':
  secret_key       => 'ii7nnoCGtP0wjub6nqnRfQx93YUV3iWG',  # your secret key here.
  hive_server_host => 'hive.example.com'
}
```

There are many more parameters to the ```cdh::hue``` class.  See the class
documentation in manifests/hue.pp.

If you include ```cdh::hive``` or ```cdh::oozie``` classes on this node,
Hue will be configured to run its Hive and Oozie apps.


# HBase

## HBase Master

```puppet
$hbase_version = '1.0.0+cdh5.4.2+142-1.cdh5.4.2.p0.4~wheezy-cdh5.4.2'
class { 'cdh::hbase':
  version         => $hbase_version,
  namenode_host   => 'namenode.domain.org',
  zookeeper_hosts => [
    'zk1.domain.org',
    'zk2.domain.org',
    'zk3.domain.org'
  ],
  hbase_backup_master_hosts      => 'backup-namenode1.domain.org,backup-namenode2.domain.org'
}
class { 'cdh::hbase::master':
  version => $hbase_version
}
```

## HBase Slave (RegionServer and Thrift server)

```puppet
$hbase_version = '1.0.0+cdh5.4.2+142-1.cdh5.4.2.p0.4~wheezy-cdh5.4.2'
class { 'cdh::hbase':
  version                   => $hbase_version,
  namenode_host             => 'namenode.domain.org',
  zookeeper_hosts           => [
    'zk1.domain.org',
    'zk2.domain.org',
    'zk3.domain.org'
  ],
  hbase_regionserver_codecs => ['snappy']
}
class { 'cdh::hbase::slave':
  version => $hbase_version
}
```
