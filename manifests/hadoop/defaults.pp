# == Class cdh::hadoop::defaults
# Default parameters for cdh::hadoop configuration.
#
class cdh::hadoop::defaults {
    $cluster_name = 'cdh'
    $mapreduce_enabled                        = true
    $journalnode_hosts                        = undef
    $dfs_journalnode_edits_dir                = undef

    $short_circuit_reads_enabled              = false
    $dfs_domain_socket_path                   = '/var/run/hdfs-sockets/dn'
    $block_location_tracking_enabled          = false
    $azkaban_enabled                          = false

    $datanode_mounts                          = undef
    $dfs_data_path                            = 'hdfs/dn'
    $yarn_local_path                          = 'yarn/local'
    $yarn_logs_path                           = 'yarn/logs'
    $dfs_block_size                           = 67108864 # 64MB default
    $enable_jmxremote                         = true
    $webhdfs_enabled                          = false
    $httpfs_enabled                           = true
    $mapreduce_system_dir                     = undef
    $io_file_buffer_size                      = undef
    $balance_speed                            = undef

    $mapreduce_map_tasks_maximum              = undef
    $mapreduce_reduce_tasks_maximum           = undef
    $mapreduce_job_reuse_jvm_num_tasks        = undef
    $mapreduce_reduce_shuffle_parallelcopies  = undef

    $mapreduce_map_memory_mb                  = undef
    $mapreduce_reduce_memory_mb               = undef
    $mapreduce_task_io_sort_mb                = undef
    $mapreduce_task_io_sort_factor            = undef
    $mapreduce_map_java_opts                  = undef
    $mapreduce_reduce_java_opts               = undef
    $yarn_app_mapreduce_am_resource_mb        = undef
    $yarn_app_mapreduce_am_command_opts       = undef

    $mapreduce_shuffle_port                   = undef
    $mapreduce_shuffle_memory_limit_percent   = undef
    $mapreduce_intermediate_compression       = false
    $mapreduce_intermediate_compression_codec = 'org.apache.hadoop.io.compress.DefaultCodec'
    $mapreduce_output_compression             = false
    $mapreduce_output_compression_codec       = 'org.apache.hadoop.io.compress.DefaultCodec'
    $mapreduce_output_compression_type        = 'RECORD'

    $yarn_resourcemanager_recovery_enabled    = false
    $yarn_nodemanager_resource_cpu_vcores     = undef
    $yarn_nodemanager_resource_memory_mb      = undef
    $yarn_scheduler_minimum_allocation_mb     = undef
    $yarn_scheduler_maximum_allocation_mb     = undef
    $yarn_scheduler_minimum_allocation_vcores = undef
    $yarn_scheduler_maximum_allocation_vcores = undef
    $yarn_aux_services_spark_shuffle_enabled  = false

    $fair_scheduler_template                  = 'cdh/hadoop/fair-scheduler.xml.erb'
    $fair_user_as_default_queue               = false

    $hadoop_heapsize                          = undef
    $yarn_heapsize                            = undef

    $ganglia_hosts                            = undef
    $net_topology_script_template             = undef
    $gelf_logging_enabled                     = false
    $gelf_logging_host                        = 'localhost'
    $gelf_logging_port                        = 12201

    $hadoop_classpath                         = undef
    $java_library_path                        = undef

    $lzo_enabled                              = false
    $io_compression_codec_lzo_class           = 'com.hadoop.compression.lzo.LzoCodec'
    $io_compression_codecs                    = ['org.apache.hadoop.io.compress.DefaultCodec',
                                                 'org.apache.hadoop.io.compress.GzipCodec',
                                                 'org.apache.hadoop.io.compress.BZip2Codec']

    # JMX Ports (These are not currently configurable)
    $namenode_jmxremote_port           = 9980
    $datanode_jmxremote_port           = 9981
    $resourcemanager_jmxremote_port    = 9983
    $nodemanager_jmxremote_port        = 9984
    $proxyserver_jmxremote_port        = 9985
}
