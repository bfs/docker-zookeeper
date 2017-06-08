# Zookeeper
## With options for Logs, Data Logs, and Data

## Config Options

### Environment variables

```bash
HOSTS #comma delimited, defaults to "localhost"

ZK_SERVER_ID #should be set

ZK_CLIENT_PORT #default 2181
ZK_PEER_PORT #default 2888
ZK_ELECTION_PORT #default 3888

ZK_MAX_CLIENT_CONNECTIONS #default 50
ZK_TICK_TIME #default 2000
ZK_SYNC_LIMIT #default 5

ZK_DATA_DIR #default /data
ZK_SECRETS_PATH #default /secrets

#optional if using kerberos
KERBEROS_KEYTAB_FILE #default zookeeper.keytab
KERBEROS_PRINCIPAL #should be set to enable SASL and kerberos settings

#optional java options (-Xmx, -Xms, etc)
JAVA_OPTIONS

DEBUG_CONFIG # set this to print the generated configs

```

### Volumes

Delays in writing to the dataLog can make Zookeeper sad, so folks often recommend separate disks for the dataDir and the dataLogDir.  I've exposed "data" and "data-log" as volumes so that you can attach them independently, ideally to separate physical disks.

### Using Docker Data Containers

#### Just Using Data Containers
```bash
docker run -d -v /data --name zookeeper-data ubuntu:14.04 true
docker run -d -v /data-log --name zookeeper-data-log ubuntu:14.04 ubuntu:14.04 true
```

#### Seperate Physical Disks
```bash
docker run -d -v /disk1/zookeeper/data/:/data --name zookeeper-data ubuntu:14.04 true
docker run -d -v /disk2/zookeeper/data-log/:/data-log --name zookeeper-data-log ubuntu:14.04 true
```

## Starting with Data Containers

```bash
docker run -e ZK_SERVER_ID=1 --restart=on-failure:10 --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 -e HOSTS=pet100,pet110,pet120 -m 2g --volumes-from zookeeper-data --volumes-from zookeeper-data-log boritzio/docker-zookeeper
```
