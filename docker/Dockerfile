FROM ubuntu:latest
RUN apt-get update \
  && apt-get install -y wget \
   && rm -rf /var/lib/apt/lists/*
RUN mkdir -p ~/hadoop-bin/hadoop-1.2.1/
RUN wget https://www.apache.org/dist/hadoop/core/hadoop-1.2.1/hadoop-1.2.1-bin.tar.gz -O ~/hadoop-bin/hadoop-1.2.1/hadoop.tar.gz
RUN mkdir -p ~/hive-bin/hive-0.11/
RUN wget https://archive.apache.org/dist/hive/hive-0.11.0/hive-0.11.0-bin.tar.gz -O ~/hive-bin/hive-0.11/hive.tar.gz
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true |  /usr/bin/debconf-set-selections
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN apt-get install -y oracle-java8-installer
RUN apt-get install -y oracle-java8-set-default
RUN mkdir -p ~/hadoop/hadoop-1.2.1/
RUN mkdir -p ~/hive/hive-0.11/
RUN tar -xzf ~/hadoop-bin/hadoop-1.2.1/hadoop.tar.gz -C ~/hadoop/hadoop-1.2.1/
RUN tar -xzf ~/hive-bin/hive-0.11/hive.tar.gz -C ~/hive/hive-0.11/
RUN export HADOOP_HOME=$HOME/hadoop/hadoop-1.2.1/hadoop-1.2.1/ && echo $HADOOP_HOME && echo "LS" && ls -al $HADOOP_HOME
#FIXME:
RUN printf 'export HADOOP_HOME=%s\nexport JAVA_HOME=%s\n' $HOME/hadoop/hadoop-1.2.1/hadoop-1.2.1/ /usr/ >> $HOME/.bash_profile
#RUN echo "export HADOOP_HOME=$HOME/hadoop/hadoop-1.2.1/hadoop-1.2.1/" > /etc/profile.d/hive_env_vars.sh
#RUN bin/sh /etc/profile.d/hive_env_vars.sh
RUN mkdir -p /tmp/root/
RUN mkdir -p /tmp/warehouse
RUN mkdir -p /tmp/spec-tmp-files
#CMD bash
# CMD ls
#CMD /usr/bin/java -version
CMD export HADOOP_HOME=$HOME/hadoop/hadoop-1.2.1/hadoop-1.2.1/ \
		&& export JAVA_HOME='/usr/' \
		   && echo $JAVA_HOME \
			&& ~/hive/hive-0.11/hive-0.11.0-bin/bin/hive --service hiveserver2 --hiveconf hive.server2.enable.doAs=false --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console --hiveconf hive.metastore.warehouse.dir=/tmp/warehouse
#CMD export HADOOP_HOME='~/hadoop/hadoop-1.2.1/hadoop-1.2.1/' && ~/hive/hive-0.11/hive-0.11.0-bin/bin/hiveserver2
#CMD export HADOOP_HOME=~/hadoop/hadoop-1.2.1/ && echo $HADOOP_HOME && ls -al $HADOOP_HOME && ~/hive/hive-0.11/hive-0.11.0-bin/bin/hiveserver2
