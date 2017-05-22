FROM ubuntu:latest
RUN apt-get update \
  && apt-get install -y wget \
   && rm -rf /var/lib/apt/lists/*

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true |  /usr/bin/debconf-set-selections

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java

RUN apt-get update
RUN apt-get install -y oracle-java8-installer
RUN apt-get install -y oracle-java8-set-default

ENV SHARED_FOLDER /tmp/spec-tmp-files/
ENV TMP_ROOT /tmp/root/
ENV WAREHOUSE /tmp/warehouse/

ENV HADOOP_BIN $HOME/hadoop-bin/hadoop/
ENV HIVE_BIN $HOME/hive-bin/hive/
ENV TEZ_BIN $HOME/tez-bin/tez/

ENV HADOOP_HOME $HOME/hadoop/
ENV HIVE_HOME $HOME/hive/
ENV TEZ_HOME $HOME/tez/

ENV JAVA_HOME /usr/

RUN mkdir -p $HADOOP_BIN \
    && mkdir -p $HIVE_BIN \
    && mkdir -p $TEZ_BIN \
    && mkdir -p $HADOOP_HOME \
    && mkdir -p $HIVE_HOME \
    && mkdir -p $TEZ_HOME \
    && mkdir -p $SHARED_FOLDER \
    && mkdir -p $TMP_ROOT \
    && mkdir -p $WAREHOUSE

RUN wget http://www-eu.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz -O $HADOOP_BIN/hadoop.tar.gz
RUN wget http://www-eu.apache.org/dist/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz -O $HIVE_BIN/hive.tar.gz
# RUN wget http://ftp.ps.pl/pub/apache/tez/0.8.5/apache-tez-0.8.5-bin.tar.gz -O $TEZ_BIN/tez.tar.gz

RUN tar -xzf $HADOOP_BIN/hadoop.tar.gz --strip-components=1 -C $HADOOP_HOME
RUN tar -xzf $HIVE_BIN/hive.tar.gz --strip-components=1 -C $HIVE_HOME
# RUN tar -xzf $TEZ_BIN/tez.tar.gz --strip-components=1 -C $TEZ_HOME

#CMD $HIVE_HOME/bin/hive --service metastore &
#

RUN rm -rf $HIVE_HOME/metastore_db/
RUN $HIVE_HOME/bin/schematool -initSchema -dbType derby

CMD $HIVE_HOME/bin/hive \
        --service hiveserver2 \
        --hiveconf hive.server2.enable.doAs=false \
        --hiveconf hive.server2.thrift.port=10000 \
        --hiveconf hive.root.logger=INFO,console \
        --hiveconf hive.metastore.uris=
