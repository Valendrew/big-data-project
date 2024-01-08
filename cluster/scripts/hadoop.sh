#!/usr/bin/env bash

echo "---Installing Hadoop---"

join_path() {
  local IFS="/"
  echo "$*"
}
basename() {
  # remove from the first argument the second argument
  echo "${1//$2/}"
}

SRC_FOLDER="/vagrant/downloads"
TAR_FILENAME="hadoop-3.3.6.tar.gz"
DEST_FOLDER="/home/vagrant"
HADOOP_FOLDER="hadoop"

# Check hadoop does not exist in home folder
if ! [ -d "$(join_path $DEST_FOLDER $HADOOP_FOLDER)" ]; then
  # Check if hadoop installation file exists
  if ! [ -e "$(join_path $SRC_FOLDER $TAR_FILENAME)" ]; then
    echo "Downloading Hadoop at $SRC_FOLDER"
    wget -q -P $SRC_FOLDER https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
  fi
  echo "Extracting Hadoop"
  tar -xzf "$(join_path $SRC_FOLDER $TAR_FILENAME)" -C $DEST_FOLDER
  # Rename folder to hadoop
  mv "$(join_path $DEST_FOLDER "$(basename $TAR_FILENAME '.tar.gz')")" "$(join_path $DEST_FOLDER $HADOOP_FOLDER)"
  chown --recursive vagrant:vagrant "$(join_path $DEST_FOLDER $HADOOP_FOLDER)"
fi

SRC_CONF_FOLDER="/vagrant/conf/hadoop"
DEST_CONF_FOLDER=$(join_path $DEST_FOLDER $HADOOP_FOLDER "etc" "hadoop")

# Copy configuration files
cp -R "${SRC_CONF_FOLDER}"/*.xml "${DEST_CONF_FOLDER}"

# Copy workers file
# WORKERS_FOLDER=$(join_path "$DEST_CONF_FOLDER" "workers")
cp "${SRC_CONF_FOLDER}/workers" "${DEST_CONF_FOLDER}"
# if grep "localhost" "$WORKERS_FOLDER"; then
#   sed -i '/localhost/d' "$WORKERS_FOLDER"
# fi
# if ! grep "node1" "$WORKERS_FOLDER"; then
#   echo "node1" >>"$WORKERS_FOLDER"
# fi
# if ! grep "node2" "$WORKERS_FOLDER"; then
#   echo "node2" >>"$WORKERS_FOLDER"
# fi

echo "Creating data folder"
mkdir -p "$(join_path $DEST_FOLDER 'data' 'nameNode')"
mkdir -p "$(join_path $DEST_FOLDER 'data' 'dataNode')"
chown --recursive vagrant:vagrant "$(join_path $DEST_FOLDER 'data')"

echo "Adding Hadoop environment variables"

if ! grep "export HADOOP_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" /home/vagrant/.bashrc; then
  echo "export HADOOP_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" >>/home/vagrant/.bashrc
fi
if ! grep "export HADOOP_COMMON_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" /home/vagrant/.bashrc; then
  echo "export HADOOP_COMMON_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" >>/home/vagrant/.bashrc
fi
if ! grep "export HADOOP_CONF_DIR=$(join_path $DEST_FOLDER $HADOOP_FOLDER "etc" "hadoop")" /home/vagrant/.bashrc; then
  echo "export HADOOP_CONF_DIR=$(join_path $DEST_FOLDER $HADOOP_FOLDER "etc" "hadoop")" >>/home/vagrant/.bashrc
fi
if ! grep "export HADOOP_HDFS_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" /home/vagrant/.bashrc; then
  echo "export HADOOP_HDFS_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" >>/home/vagrant/.bashrc
fi
if ! grep "export HADOOP_MAPRED_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" /home/vagrant/.bashrc; then
  echo "export HADOOP_MAPRED_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" >>/home/vagrant/.bashrc
fi
if ! grep "export HADOOP_YARN_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" /home/vagrant/.bashrc; then
  echo "export HADOOP_YARN_HOME=$(join_path $DEST_FOLDER $HADOOP_FOLDER)" >>/home/vagrant/.bashrc
fi
if ! grep "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" "$(join_path "$DEST_CONF_FOLDER" 'hadoop-env.sh')"; then
  echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >>"$(join_path "$DEST_CONF_FOLDER" 'hadoop-env.sh')"
fi

# if ! grep "PATH=/home/vagrant/hadoop/bin:/home/vagrant/hadoop/sbin:\$PATH" /home/vagrant/.profile; then
#   echo "PATH=/home/vagrant/hadoop/bin:/home/vagrant/hadoop/sbin:\$PATH" >>  /home/vagrant/.profile
# fi
# if ! grep "export PATH=${PATH}:/home/vagrant/hadoop/bin:/home/vagrant/hadoop/sbin" /home/vagrant/.bashrc; then
#   echo "export PATH=${PATH}:/home/vagrant/hadoop/bin:/home/vagrant/hadoop/sbin" >>  /home/vagrant/.bashrc
# fi