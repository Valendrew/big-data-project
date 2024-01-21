#!/usr/bin/env bash

apt-get update -y && apt-get upgrade -y
apt-get install -y python3 python3-pip python3.10-venv

join_path() {
  local IFS="/"
  echo "$*"
}

# Variable which is false
TO_RUN=false

if [[ "$TO_RUN" = true ]]; then
  PROJECT_FOLDER="/home/vagrant/project"
  VENV_NAME="env"
  if ! grep "export PYSPARK_PYTHON=" /home/vagrant/.bashrc; then
    echo "export PYSPARK_PYTHON=$(join_path '.' ${VENV_NAME} bin python3)" >>/home/vagrant/.bashrc
  fi
  if ! grep "export PYSPARK_HADOOP_VERSION=3" /home/vagrant/.bashrc; then
    echo "export PYSPARK_HADOOP_VERSION=3" >>/home/vagrant/.bashrc
  fi
  if ! grep "export PYSPARK_DRIVER_PYTHON=jupyter" /home/vagrant/.bashrc; then
    echo "export PYSPARK_DRIVER_PYTHON=jupyter" >>/home/vagrant/.bashrc
  fi
  if ! grep "export PYSPARK_DRIVER_PYTHON_OPTS=notebook --no-browser --ip=0.0.0.0" /home/vagrant/.bashrc; then
    echo "export PYSPARK_DRIVER_PYTHON_OPTS='notebook --no-browser --ip=0.0.0.0'" >>/home/vagrant/.bashrc
  fi
  if ! grep "export PYARROW_IGNORE_TIMEZONE=1" /home/vagrant/.bashrc; then
    echo "export PYARROW_IGNORE_TIMEZONE=1" >>/home/vagrant/.bashrc
  fi

  # Create project folder and virtual environment
  mkdir -p ${PROJECT_FOLDER}
  python3 -m venv "$(join_path ${PROJECT_FOLDER} ${VENV_NAME})"
  chown -R vagrant:vagrant ${PROJECT_FOLDER}
  chown -R vagrant:vagrant "$(join_path ${PROJECT_FOLDER} ${VENV_NAME})"

  # Upgrade pip and install packages
  $(join_path ${PROJECT_FOLDER} ${VENV_NAME} bin pip) install --upgrade pip
  $(join_path ${PROJECT_FOLDER} ${VENV_NAME} bin pip) install venv-pack pandas pyspark pyarrow jupyter matplotlib

  # Create archive with virtual environment
  $(join_path ${PROJECT_FOLDER} ${VENV_NAME} bin python) -m venv_pack -p "$(join_path ${PROJECT_FOLDER} ${VENV_NAME})" -o "$(join_path ${PROJECT_FOLDER} pyspark_venv.tar.gz)"
  chown vagrant:vagrant "$(join_path ${PROJECT_FOLDER} pyspark_venv.tar.gz)"

  SPARK_CONF_PATH="/home/vagrant/spark/conf/spark-defaults.conf"
  sed -i '/spark.yarn.dist.archives/d' ${SPARK_CONF_PATH}
  echo "spark.yarn.dist.archives $(join_path ${PROJECT_FOLDER} pyspark_venv.tar.gz#${VENV_NAME})" >>${SPARK_CONF_PATH}
  # if ! grep "spark.yarn.dist.archives $(join_path ${PROJECT_FOLDER} pyspark_venv.tar.gz#${VENV_NAME})" ${SPARK_CONF_PATH}; then
    # echo "spark.yarn.dist.archives $(join_path ${PROJECT_FOLDER} pyspark_venv.tar.gz#${VENV_NAME})" >>${SPARK_CONF_PATH}
  # fi
  # pip3 install matplotlib pandas seaborn jupyter numpy pyspark
  # pip3 install jupyter pandas pyarrow numpy
fi