# San Francisco Crime Classification - Big Data Project

## Description

The goal of this project is to predict the **category of crimes** that occurred in the city of San Francisco. The dataset contains nearly 12 years of crime reports from across all of San Francisco's neighborhoods. Given **time and location**, the goal is to predict the category of the crime.

The project is divided into two parts:
- The first one is the data analysis, where the data is cleaned and analyzed to extract useful information.
- The second one is the machine learning part, where the data is used to train a model that can predict the category of a crime given the time and the location.

The project is executed on a **Hadoop Cluster** with **Spark** and **Jupyter Notebook** installed. The cluster is created using **Vagrant** and **VirtualBox**.

This contribution is part of the **Text Mining-Big Data-Data Mining** course at the University of Bologna, in the Master's Degree in Artificial Intelligence.

## Structure

```
./
|
├── cluster/
|   │
|   ├── conf/
|   │   └── configuration files for Hadoop and Spark
|   │
|   ├── data/
|   │  └── dataset for the project
|   │
|   ├── downloads/
|   │   └── downloaded files from the internet
|   │
|   ├── scripts/
|   │   └── provisioning scripts for master and worker nodes
|   │
|   ├── utils/
|   │   └── utility scripts for running services (HDFS, YARN, Spark)
|   │
|   └── VagrantFile
|        └── configuration for the cluster
|
├── project.ipynb
|    └── Jupyter Notebook for the project
|
└── README.md
|    └── Explanation of the project
|
├── presentation.pdf
|    └── Presentation of the project
  
```

## Installation

### Vagrant

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

### Hadoop Cluster

- Master node maintains knowledge about the distributed file system, like the inode table on an ext3 filesystem, and schedules resources allocation; it hosts two daemons
  - The NameNode manages the distributed file system and knows where stored data blocks inside the cluster are
  - The ResourceManager manages the YARN jobs and takes care of scheduling and executing processes on worker nodes
- Worker nodes store the actual data and provide processing power to run the jobs; they hosts two daemons
  - The DataNode manages the physical data stored on the node; it’s named, NameNode.
  - The NodeManager manages execution of tasks on the node
- [HDFS commands](https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/#run-and-monitor-hdfs)
  - Start HDFS: `start-dfs.sh`
    - In master node: `NameNode, SecondaryNameNode`
    - In worker node: `DataNode`
  - Stop HDFS: `stop-dfs.sh`
  - Format HDFS: `hdfs namenode -format`
    - Must be run only once, **before** starting HDFS for the first time
  - Create user directory: `hdfs dfs -mkdir -p /user/vagrant`
    - The `vagrant` subdirectory must match the username
  - **Commands**: 
    - Create a directory: `hdfs dfs -mkdir DIR`
    - Put a file: `hdfs dfs -put FILE DIR`
    - List the content of the directory: `hdfs dfs -ls DIR`
    - Output the content of the file: `hdfs dfs -cat DIR/FILE`
    - Status of the HDFS: `hdfs dfsadmin -report`
- [YARN commands](https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/#run-yarn)
  - Run YARN: `start-yarn.sh`
    - In master node: `ResourceManager`
    - In worker node: `NodeManager`
  - Stop YARN: `stop-yarn.sh`
  - **Commands**: 
    - Run a MapReduce job: `yarn jar JAR_FILE CLASS_NAME INPUT OUTPUT`
    - List the running nodes: `yarn node -list`
    - List the running applications: `yarn application -list`
- **MAPRED commands**:
  - Run MAPRED: `mapred --daemon start historyserver`
    - In master node: `JobHistoryServer`
  - Stop MAPRED: `mapred --daemon stop historyserver`
- **Test the cluster**: 
  ```bash
    hdfs dfs -mkdir -p /user/vagrant/books
    hdfs dfs -put /vagrant/books /user/vagrant
    yarn jar hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount "books/*" output
  ```
  - **View results**: `hdfs dfs -cat output/*`
- **Web UI**: 
  - HDFS Web UI: http://node-master:9870/
  - Yarn Web UI: http://node-master:8088
  - MapReduce Web UI: http://node-master:19888

### Spark

- Create the spark-logs folder in the HDFS: `hdfs dfs -mkdir /spark-logs`
- Configuration file: `spark/conf/spark-defaults.conf`
- **History server**:
  - Run: `spark/sbin/start-history-server.sh`
    - In master node: `HistoryServer`
  - Stop: `spark/sbin/stop-history-server.sh`
- **Test the cluster**: 
  ```bash
  spark-submit --deploy-mode client --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_2.11-2.2.0.jar 10
  ```
    - `--master yarn` can be omitted since `spark.master` is set in the configuration file
    - `-executor-memory` can be omitted since `spark.executor.memory` is set in the configuration file
    - `--num-executors` can be omitted since `spark.executor.instances` is set in the configuration file
- **Web UI**: 
  - Spark Web UI: http://node-master:4040
  - History Server Web UI: http://node-master:18080

### Python

- Run jupyter notebook: `jupyter notebook --ip=0.0.0.0 --no-browser`
- Virtual environment:
  - Create environment: `python3 -m venv pyspark_venv`
  - Activate environment: `source pyspark_venv/bin/activate`
  - Create venv-pack: `venv-pack -o pyspark_venv.tar.gz`
- **Run PySpark shell**: 
  ```bash
  pyspark --archives pyspark_venv.tar.gz#pyspark_venv
  $SPARK_HOME/bin/spark-submit --deploy-mode client app.py
  ```	

### Misc

- Command to view java processes: `jps`