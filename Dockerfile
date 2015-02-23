FROM boritzio/docker-base-java

RUN apt-get install -y zookeeper

ADD zoo.cfg /etc/zookeeper/conf/zoo.cfg

EXPOSE 2181 2888 3888

VOLUME ["/data", "/data-log"]

ADD setup.sh /etc/my_init.d/zookeeper.sh
