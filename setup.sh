#!/bin/bash

######################################### SETUP PARAMETERS #########################################

# Host server environment
# You can have corresponding values for qa/prod.
# Enables switching environment dependent variables, for ex: switching between prod/qa DB connections.
HOST_ENV="localhost"

# Airflow UI admin login
AIRFLOW_ADMIN_USER="airflow"
AIRFLOW_ADMIN_PASSWORD="airflow"

# Default Kafka servers#
# BOOTSTRAP_SERVERS: kafka-broker:19091
# ZOOKEEPER_CONNECT: zookeeper:2181
# Incase required to add more, add comma delimited brokers in the .env file;
# then restart airflow services in docker compose
BOOTSTRAP_SERVERS="kafka-broker:19091"
ZOOKEEPER_CONNECT="zookeeper:2181"
# Create default topic and create partitions on startup. This will be used as Airflow variable to spawn
# corresponding number of consumer tasks in DAG.
DEMO_TOPIC_NAME="myapp"
DEMO_TOPIC_PARTITIONS="2"

# Pentaho setup
# PDI_RELEASE and PDI_VERSION builds the below PDI download link
# https://sourceforge.net/projects/pentaho/files/Pentaho-9.2/client-tools/pad-ce-9.2.0.0-290.zip/download
PDI_RELEASE="9.2"
PDI_VERSION="9.2.0.0-290"
# Environment variable inside the PDI containers;
# Defines the min. and max. runtime memory a PDI container can use
PENTAHO_DI_JAVA_OPTIONS="-Xms1g -Xmx2g"

##################################################################################################

if [ $HOST_ENV == "prod" ]|| [ $HOST_ENV == "sandbox" ]|| [ $HOST_ENV == "localhost" ];then

# Create required folders
mkdir -p \
./docker/airflow/logs \
./docker/airflow/plugins \
./docker/pentaho/logs \
./docker/pentaho/plugins \
./docker/pentaho/simple-jndi \
./docker/pentaho/.kettle

# Create an empty JNDI file for PDI
touch docker/pentaho/simple-jndi/jdbc.properties

# Environment dependent variables
if [ $HOST_ENV == "prod" ] || [ $HOST_ENV == "sandbox" ];then
# Set memory requirement for PDI
PENTAHO_DI_JAVA_OPTIONS="-Xms4g -Xmx10g"
fi

# Set environment variables
echo -e "\
HOST_ENV=$HOST_ENV\n\
AIRFLOW_ADMIN_USER=$AIRFLOW_ADMIN_USER\n\
AIRFLOW_ADMIN_PASSWORD=$AIRFLOW_ADMIN_PASSWORD\n\
AIRFLOW_UID=$(id -u)\n\
AIRFLOW_GID=0\n\
AIRFLOW_VAR_DEMO_TOPIC_NAME=$DEMO_TOPIC_NAME\n\
AIRFLOW_VAR_DEMO_TOPIC_CONSUMERS=$DEMO_TOPIC_PARTITIONS\n\
BOOTSTRAP_SERVERS=$BOOTSTRAP_SERVERS\n\
DEMO_TOPIC_NAME=$DEMO_TOPIC_NAME\n\
DEMO_TOPIC_PARTITIONS=$DEMO_TOPIC_PARTITIONS\n\
HOST_PDI_SRC_PATH=$PWD/src/ktr\n\
HOST_PDI_KET_PATH=$PWD/docker/pentaho/.kettle\n\
HOST_PDI_JND_PATH=$PWD/docker/pentaho/simple-jndi\n\
HOST_PDI_LOG_PATH=$PWD/docker/pentaho/logs\n\
HOST_PDI_PLG_PATH=$PWD/docker/pentaho/plugins\n\
PENTAHO_UID=$(id -u)\n\
PENTAHO_GID=0\n\
PENTAHO_DI_JAVA_OPTIONS=\"$PENTAHO_DI_JAVA_OPTIONS\"\n\
" > .env

# Create kettle variables
echo -e "HOST_ENV=$HOST_ENV\n\
BOOTSTRAP_SERVERS=$BOOTSTRAP_SERVERS\n\
ZOOKEEPER_CONNECT=$ZOOKEEPER_CONNECT\n\
" > ./docker/pentaho/.kettle/kettle.properties

# Build PDI image
docker build \
--build-arg PDI_RELEASE=$PDI_RELEASE \
--build-arg PDI_VERSION=$PDI_VERSION \
--build-arg PENTAHO_UID=$(id -u) \
--build-arg PENTAHO_GID=0 \
-f docker/pentaho/Dockerfile -t pdi .

else
echo "Invalid HOST_ENV argument passed!\nAllowed values: prod/sandbox/localhost"
exit 1
fi