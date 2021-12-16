FROM openjdk:11.0.11-jdk-slim

WORKDIR /opt

ENV HADOOP_VERSION=3.1.2
ENV METASTORE_VERSION=3.1.2

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-${METASTORE_VERSION}-bin
ENV JAR_DROP=${HADOOP_HOME}/share/hadoop/common/lib

RUN  apt-get update -y && apt-get install -y net-tools netcat curl vim && \

curl -L https://downloads.apache.org/hive/hive-${METASTORE_VERSION}/apache-hive-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
    rm -rf  mysql-connector-java-8.0.19 && \
    curl -L https://repo1.maven.org/maven2/io/prestosql/hive/hive-apache/3.0.0-6/hive-apache-3.0.0-6.jar -o ${JAR_DROP}/hive-apache-3.0.0-6.jar && \
    curl -L https://repo1.maven.org/maven2/javax/activation/javax.activation-api/1.2.0/javax.activation-api-1.2.0.jar -o ${JAR_DROP}/avax.activation-api-1.2.0.jar

COPY conf/metastore-site.xml ${HIVE_HOME}/conf/hive-site.xml
COPY scripts/entrypoint.sh /entrypoint.sh
#these seem to be needed for a few things. that aren't in the default distrib:
# * javax.activation-api-1.2.0.jar => not included in hadoop-3.1.2 (it is included in hadoop-3.3).  necessary apparantly for some create-partition actions
# * hive-apache-3.0.0-6.jar => this was 'borrowed' from presto's hive fork. It includes a MaterializationsCacheCleanerTask class, 
# which is needed for the relevant hive-site.xml parameter 

#COPY jars/* ${HADOOP_HOME}/share/hadoop/common/lib/ 

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]

