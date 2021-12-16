#!/bin/sh

export HADOOP_HOME=/opt/hadoop-3.1.2
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.271.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.1.2.jar

export JAVA_HOME=/usr/local/openjdk-11

echo "sleeping for 60"
sleep 60
/opt/apache-hive-3.1.2-bin/bin/schematool -initSchema -dbType mysql
/opt/apache-hive-3.1.2-bin/bin/hive --service metastore
