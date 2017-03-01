FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && \
  apt-get -qq install -y wget software-properties-common && \
  add-apt-repository ppa:webupd8team/java && \
  apt-get -qq update && \
  (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true |  /usr/bin/debconf-set-selections) && \
  apt-get -qq install -y oracle-java8-installer oracle-java8-set-default

ENV INSTALL_DIR=/opt
ENV SHARED_FOLDER=/tmp/spec-tmp-files \
  TMP_HOME=/tmp/home \
  WAREHOUSE=/tmp/warehouse \
  HADOOP_HOME=$INSTALL_DIR/hadoop \
  HIVE_HOME=$INSTALL_DIR/hive \
  JAVA_HOME=/usr

RUN mkdir -p $HADOOP_HOME $HIVE_HOME $SHARED_FOLDER $TMP_HOME $WAREHOUSE

RUN wget https://www.apache.org/dist/hadoop/core/hadoop-1.2.1/hadoop-1.2.1-bin.tar.gz --quiet -O /tmp/hadoop.tar.gz && \
  wget https://archive.apache.org/dist/hive/hive-0.11.0/hive-0.11.0-bin.tar.gz --quiet -O /tmp/hive.tar.gz && \
  tar -xzf /tmp/hadoop.tar.gz --strip-components=1 -C $HADOOP_HOME && \
  tar -xzf /tmp/hive.tar.gz --strip-components=1 -C $HIVE_HOME

WORKDIR $TMP_HOME

ENTRYPOINT $HIVE_HOME/bin/hive \
          --service hiveserver2 \
          --hiveconf hive.server2.enable.doAs=false \
          --hiveconf hive.server2.thrift.port=10000 \
          --hiveconf hive.root.logger=INFO,console  \
          --hiveconf hive.metastore.warehouse.dir=$WAREHOUSE
