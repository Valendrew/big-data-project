#!/usr/bin/env bash

echo "---Bootstrapping---"

apt-get update -y && apt-get upgrade -y
apt-get install -y default-jre openjdk-11-jdk-headless python3 libopenblas-base

# Variable which is false
TO_RUN=false
# Run the following commands only if the variable is true
if [ "$TO_RUN" = true ]; then

    # Remove localhost from /etc/hosts
    sed -i '/127.0.2.1/d' /etc/hosts

    BASE_IP=192.168.50
    join_ip() {
        local IFS="."
        echo "$*"
    }

    # Add master node ip
    LINE="$(join_ip $BASE_IP 2) node-master"
    if ! grep "$LINE" /etc/hosts; then
        echo "$LINE" >>/etc/hosts
    fi
    # Add worker nodes ip
    for i in {1..2}; do
        LINE="$(join_ip $BASE_IP $((i + 2))) node$i"
        if ! grep "$LINE" /etc/hosts; then
            echo "$LINE" >>/etc/hosts
        fi
    done

    if ! grep "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" /home/vagrant/.bashrc; then
        echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >>/home/vagrant/.bashrc
    fi
fi
