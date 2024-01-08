# Projects

## Installations

### Bootstrap

The `bootstrap.sh` script will install the necessary packages and dependencies for the other scripts to run properly.

The `/etc/hosts` file will be modified to include the IP addresses and hostnames of the nodes in the cluster. Additionally, the `127.0.2.1` line will be removed, as it is causing problems, since it is not the IP address of the master node.

### SSH keys

The `ssh.sh` scripts are designed to be run differently in the master and the slaves. In the master, the script will copy both the public and private keys to the node, while in the slaves, only the public key will be copied. 

### Hadoop

Hadoop is a framework for distributed storage and processing of large data sets which are stored in a cluster of computers. It allows to scale up from single server to thousands of machines, each offering local computation and storage.

![Alt text](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/images/hdfsarchitecture.png "HDFS Architecture")

In the HDFS architecture, the NameNode is the master and the DataNodes are the slaves.

The NameNode daemon manages the file system namespace and the access to the files by clients, while the DataNodes manage the storage attached to the nodes that they run on.

In the setup we are going to use, Hadoop will be installed on a 3-node cluster, with one master and two slaves, but it can be scaled up to more nodes just by changing the configuration files.

In the `hadoop.sh` script, we will install Hadoop in all the nodes and copy the same configuration files to all of them. The script will also create the necessary folders and set the environment variables in the `.bashrc` file and the `hadoop-env.sh` file.

The `workers` file will contain the IP addresses/hostname of the slaves, in our case its content will be:

```bash
node1
node2
```

In the `hdfs-site.xml` file, we will set the replication factor to 2, so that each block will be replicated on two DataNodes.

```xml
<property>
    <name>dfs.replication</name>
    <value>2</value>
</property>
```

Additionally, we will set the NameNode and DataNode folders in the `hdfs-site.xml` file:

```xml
<property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///home/hadoop/hadoop_data/nameNode</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///home/hadoop/hadoop_data/dataNode</value>
</property>
```

The `dataNode` folder contains the directories on the local filesystem where the DataNode store the blocks. The `nameNode` folder contains the directory where the NameNode stores the namespace and transaction logs in the local filesystem.

References:
[Architecture](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)
[Cluster Setup](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html)

### Spark

Spark is a unified analytics engine for large-scale data processing. It provides high-level APIs in Java, Scala, Python and R, and an optimized engine that supports general execution graphs. 

It also supports a rich set of higher-level tools including Spark SQL for SQL and structured data processing, MLlib for machine learning, GraphX for graph processing, and Spark Streaming.

In the current setup, we will install Spark in the master node since it will be the one running the Spark jobs, the slaves won't need to have Spark installed since the Spark jars will be available on the HDFS. 

The `HADOOP_CONF_DIR` environment variable will be set to the `etc/hadoop` folder, so that Spark can find the Hadoop configuration files, in order to connect to the HDFS and the YARN Resource Manager to distribute the Spark jobs.

In the cluster mode, the Spark driver runs inside an application master process which is managed by YARN on the cluster, and the client can go away after initiating the application. In the client mode, the driver runs in the client process, and the application master is only used for requesting resources from YARN.

The SparkContext connects to the YARN Resource Manager to request executors to run the Spark jobs. The executors are the processes that run computations and store data for the Spark application

![Alt text](https://spark.apache.org/docs/latest/img/cluster-overview.png "Spark Cluster Overview")

References:
[Spark](https://spark.apache.org/docs/latest/)
[Spark on YARN](https://spark.apache.org/docs/latest/running-on-yarn.html)
[Saprak Cluster Mode](https://spark.apache.org/docs/latest/cluster-overview.html)