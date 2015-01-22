FROM ubuntu:14.04

RUN apt-get update && apt-get install -y zookeeper

ADD zoo.cfg /etc/zookeeper/conf/zoo.cfg

EXPOSE 2181 2888 3888

VOLUME ["/data", "/data-log"]

ADD setup.sh /var/lib/zookeeper/setup.sh

ENTRYPOINT ["/var/lib/zookeeper/setup.sh"]
