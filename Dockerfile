FROM boritzio/docker-base-java

RUN apt-get install -y zookeeper

ADD zoo.cfg /etc/zookeeper/conf/zoo.cfg

VOLUME ["/data", "/data-log"]

ADD setup.sh /etc/my_init.d/zookeeper.sh
