#!/usr/bin/env bash

echo "---Installing Spark---"

join_path() {
  local IFS="/"
  echo "$*"
}
basename() {
  # remove from the first argument the second argument
  echo "${1//$2/}"
}

SRC_FOLDER="/vagrant/downloads"
TAR_FILENAME="spark-3.4.1-bin-hadoop3.tgz"
DEST_FOLDER="/home/vagrant"
SPARK_FOLDER="spark"

# Check spark does not exist in home folder
if ! [ -d "$(join_path $DEST_FOLDER $SPARK_FOLDER)" ]; then
  # Check if spark installation file exists
  if ! [ -e "$(join_path $SRC_FOLDER $TAR_FILENAME)" ]; then
    echo "Downloading Spark at $SRC_FOLDER"
    wget -q -P $SRC_FOLDER https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz
  fi
  echo "Extracting spark"
  tar -xzf "$(join_path $SRC_FOLDER $TAR_FILENAME)" -C $DEST_FOLDER
  # Rename folder to spark
  mv "$(join_path $DEST_FOLDER "$(basename $TAR_FILENAME '.tgz')")" "$(join_path $DEST_FOLDER $SPARK_FOLDER)"
  chown --recursive vagrant:vagrant "$(join_path $DEST_FOLDER $SPARK_FOLDER)"
fi

# Add Spark environment variables
echo "Adding Spark environment variables"

# if ! grep "export PATH=/home/vagrant/spark/bin:\$PATH" /home/vagrant/.profile; then
# echo "export PATH=/home/vagrant/spark/bin:\$PATH" >>  /home/vagrant/.profile
# fi
if ! grep "export SPARK_HOME=$(join_path $DEST_FOLDER $SPARK_FOLDER)" /home/vagrant/.profile; then
  echo "export SPARK_HOME=$(join_path $DEST_FOLDER $SPARK_FOLDER)" >>/home/vagrant/.profile
fi
if ! grep "export LD_LIBRARY_PATH=/home/vagrant/hadoop/lib/native:$LD_LIBRARY_PATH" /home/vagrant/.profile; then
  echo "export LD_LIBRARY_PATH=/home/vagrant/hadoop/lib/native:$LD_LIBRARY_PATH" >>/home/vagrant/.profile
fi

SRC_CONF_FOLDER="/vagrant/conf/spark"
DEST_CONF_FOLDER=$(join_path $DEST_FOLDER $SPARK_FOLDER "conf")
cp -R "${SRC_CONF_FOLDER}"/*.conf "${DEST_CONF_FOLDER}"

# if ! grep "spark.yarn.dist.archives /home/vagrant/project/pyspark_venv.tar.gz#pyspark_venv" ${HOME_PATH}${SPARK_FOLDER}/conf/spark-defaults.conf; then
#   echo "spark.yarn.dist.archives /home/vagrant/project/pyspark_venv.tar.gz#pyspark_venv" >>  ${HOME_PATH}${SPARK_FOLDER}/conf/spark-defaults.conf
# fi
# if ! grep "export SPARK_LOCAL_IP=192.168.50.2" /home/vagrant/.profile; then
#   echo "export SPARK_LOCAL_IP=192.168.50.2" >>  /home/vagrant/.profile
# fi
