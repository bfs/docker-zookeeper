#!/bin/bash



#default
HOSTS=${HOSTS:-"localhost"}


#read HOSTS into HOSTS_ARRAY
IFS=', ' read -a HOSTS_ARRAY <<< "$HOSTS"

#-------zookeeper config----------#
export ZOOCFGDIR="/etc/zookeeper/conf"

#data paths
export ZK_DATA_DIR=${ZK_DATA_DIR:-"/data"}
export ZK_DATA_LOG_DIR=${ZK_DATA_LOG_DIR:-"/data-log"}

#secrets path
export ZK_SECRETS_PATH=${ZK_SECRETS_PATH:-"/secrets"}

#connection settings
export ZK_MAX_CLIENT_CONNECTIONS=${ZK_MAX_CLIENT_CONNECTIONS:-"50"}
export ZK_TICK_TIME=${ZK_TICK_TIME:-"2000"}
export ZK_SYNC_LIMIT=${ZK_SYNC_LIMIT:-"5"}
export ZK_INIT_LIMIT=${ZK_INIT_LIMIT:-"10"}

#KERBEROS_SETTINGS
export KERBEROS_KEYTAB_FILE=${KEBEROS_KEYTAB_FILE:-"zookeeper.keytab"}

# JVM options
export JAVA_OPTIONS=${JAVA_OPTIONS:-}


mkdir -p $ZK_DATA_DIR
mkdir -p $ZK_DATA_LOG_DIR
mkdir -p $ZK_SECRETS_PATH



export ZK_CLIENT_PORT=${ZK_CLIENT_PORT:-"2181"}
export ZK_PEER_PORT=${ZK_PEER_PORT:-"2888"}
export ZK_ELECTION_PORT=${ZK_ELECTION_PORT:-"3888"}

echo $ZK_SERVER_ID > $ZOOCFGDIR/myid
cp $ZOOCFGDIR/myid $ZK_DATA_DIR/myid

cat /tmp/zoo.cfg | mo > $ZOOCFGDIR/zoo.cfg

for i in "${!HOSTS_ARRAY[@]}"; do 
  echo "server.$(($i+1))=${HOSTS_ARRAY[$i]}:$ZK_PEER_PORT:$ZK_ELECTION_PORT" >> $ZOOCFGDIR/zoo.cfg
done


if [ -n "$KERBEROS_PRINCIPAL" ]; then  

  echo "export JVMFLAGS=\"-Djava.security.auth.login.config=$ZOOCFGDIR/jaas.conf\"" > $ZOOCFGDIR/java.env

  echo "
 
#SASL Settings
authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
jaasLoginRenew=3600000
kerberos.removeHostFromPrincipal=true
kerberos.removeRealmFromPrincipal=true
  
" >> $ZOOCFGDIR/zoo.cfg 

  cat /tmp/jaas.conf | mo > /etc/zookeeper/conf/jaas.conf
fi

if [ -n "$DEBUG_CONFIG" ]; then
  tail -n+1 $ZOOCFGDIR/*
fi
#---------------------------------#


#-------start zookeeper-----------#


/usr/bin/java -cp \
  /etc/zookeeper/conf:/usr/share/java/jline.jar:/usr/share/java/log4j-1.2.jar:/usr/share/java/xercesImpl.jar:/usr/share/java/xmlParserAPIs.jar:/usr/share/java/netty.jar:/usr/share/java/slf4j-api.jar:/usr/share/java/slf4j-log4j12.jar:/usr/share/java/zookeeper.jar \
  $JAVA_OPTIONS \
  -Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.local.only=false \
  -Dzookeeper.root.logger=INFO,CONSOLE \
  org.apache.zookeeper.server.quorum.QuorumPeerMain \
  /etc/zookeeper/conf/zoo.cfg

#---------------------------------#
