# Instruction

## Notes

- Change spark.executor.memory to 1G
- Remove spark/bin from hadoop.sh
- Check PATH is correctly set
- `-Dio.netty.tryReflectionSetAccessible=true` since JDK11 is installed

## Vagrant

- Install [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
- Install [Oracle Virtual Box](https://www.virtualbox.org/wiki/Downloads)
  - On Windows, firstly install  [Microsoft Visual C++ 2019 Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170)
- Create a new virtual machine
  - `vagrant init box_name`, for example `box_name` could be `ubuntu/jammy64`
  - `vagrant up` to run the virtual machine
  - `vagrant ssh` to SSH into the machine, with multi-machine the machine name must be specified
  - `vagrant reload` to reload the changes in the VagrantFile
  - `vagrant logout` to logout from the machine
  - `vagrant destroy` to stop and remove the machine
- Vagrant shares a directory at `/vagrant` with the directory on the host containing the Vagrantfile
  - Add new [synced folder](https://developer.hashicorp.com/vagrant/docs/synced-folders/basic_usage)
- Add a provisioning script in VagrantFile
  - `config.vm.provision :shell, path: "filename.sh"`
- Forward a port from the host machine to the guest machine
  - `config.vm.network :forwarded_port, guest: guest_port, host: host_port`
  - Additional networking [documentation](https://developer.hashicorp.com/vagrant/docs/networking)

## Hadoop Cluster

- Master node maintains knowledge about the distributed file system, like the inode table on an ext3 filesystem, and schedules resources allocation; it hosts two daemons
  - The NameNode manages the distributed file system and knows where stored data blocks inside the cluster are
  - The ResourceManager manages the YARN jobs and takes care of scheduling and executing processes on worker nodes
- Worker nodes store the actual data and provide processing power to run the jobs; they hosts two daemons
  - The DataNode manages the physical data stored on the node; it’s named, NameNode.
  - The NodeManager manages execution of tasks on the node
- [HDFS commands](https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/#run-and-monitor-hdfs)
  - `hdfs namenode -format`: format HDFS only in the NameNode node
  - `start-dfs.sh`: start HDFS
    - In master node: `NameNode, SecondaryNameNode`
    - In worker node: `DataNode`
  - `hdfs dfs -mkdir -p /user/vagrant`: create the hdfs folder
    - The `vagrant` subdirectory must match the username
  - `stop-dfs.sh`: stop HDFS
  - `jps`: monitor running processes
  - `hdfs dfsadmin -report`: report the status of the HDFS
  - **Testing DFS**: 
    - Create a directory: `hdfs dfs -mkdir DIR`
    - Put a file (e.g. alice.txt): `hdfs dfs -put FILE DIR`
    - Output the content of the file: `hdfs dfs -cat DIR/FILE`
- [YARN commands](https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/#run-yarn)
  - `start-yarn.sh`: start YARN
    - In master node: `ResourceManager`
    - In worker node: `NodeManager`
  - `stop-yarn.sh`: stop YARN
  - `jps`: monitor running processes
  - `yarn node -list`: list the running nodes in the cluster
  - `yarn application -list`: list the running applications in the cluster
- MAPRED commands: 
  - Run: `mapred --daemon start historyserver`
    - In master node: `JobHistoryServer`
  - Stop: `mapred --daemon stop historyserver`
- Command to test: 
  ```bash
  yarn jar hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount "books/*" output
  ```
  - View results with `hdfs dfs -cat output/*`
- HDFS Web UI: http://node-master:9870/
- Yarn Web UI: http://node-master:8088

## Spark

- Create the spark-logs folder in the HDFS: `hdfs dfs -mkdir /spark-logs`
- Configuration file: `spark/conf/spark-defaults.conf`
- Spark history server:
  - Run: `spark/sbin/start-history-server.sh`
    - In master node: `HistoryServer`
  - Stop: `spark/sbin/stop-history-server.sh`
- Command to test: 
  ```bashx
  spark-submit --deploy-mode client --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_2.11-2.2.0.jar 10
  ```
    - `--master yarn` can be omitted since `spark.master` is set in the configuration file
    - `-executor-memory` can be omitted since `spark.executor.memory` is set in the configuration file
    - `--num-executors` can be omitted since `spark.executor.instances` is set in the configuration file
- History Server Web UI: http://node-master:18080
- Spark YARN configuration: [LINK](https://spark.apache.org/docs/latest/running-on-yarn.html#configuring-yarn)
  - Setup different YARN queue: `spark.yarn.queue`

## Python

- Run jupyter notebook: `jupyter notebook --ip=0.0.0.0 --no-browser`
- Create venv-pack: `venv-pack -o pyspark_venv.tar.gz`
- Venv
  - Create environment: `python3 -m venv pyspark_venv`
  - Activate environment: `source pyspark_venv/bin/activate`
- Run pyspark shell: `pyspark --archives pyspark_venv.tar.gz#pyspark_venv`
- `$SPARK_HOME/bin/spark-submit --deploy-mode client app.py`