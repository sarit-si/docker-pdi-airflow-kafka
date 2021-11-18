# Get Base image
FROM openjdk:8-jre

LABEL maintainer="saritkumarsi@gmail.com" \
      description="Docker file builds image with Pentaho Data Integration"

# Set PDI user with permissions same as the Host machine.
ARG PDI_RELEASE
ARG PDI_VERSION
ARG PENTAHO_GID
ARG PENTAHO_UID

# Set required environment vars
ENV PDI_RELEASE=${PDI_RELEASE} \
    PDI_VERSION=${PDI_VERSION} \
    MYSQL_JAVA_VERSION=5.1.49 \
    PENTAHO_JAVA_HOME=/usr/local/openjdk-8 \
    PENTAHO_HOME=/home/pentaho \
    PENTAHO_UID=${PENTAHO_UID} \
    PENTAHO_GID=${PENTAHO_GID} \
    PENTAHO_USER=pentaho \
    KETTLE_HOME=/opt/data-integration \
    PATH=${KETTLE_HOME}:${PATH}

# Create Pentaho user home directory and required sub-folders
RUN mkdir -p ${PENTAHO_HOME}/pdi \
# Create Pentaho group passed as PENTAHO_GID arg
    && groupadd -r ${PENTAHO_GID} \
# Create Pentaho user with PENTAHO_UID same as Host UID, and assign to new group
    && useradd -s /bin/bash -d ${PENTAHO_HOME} -r -g ${PENTAHO_GID} -u ${PENTAHO_UID} ${PENTAHO_USER} \
# Download PDI and save in PENTAHO_HOME
    && /usr/bin/wget --progress=dot:giga \
    https://sourceforge.net/projects/pentaho/files/Pentaho-${PDI_RELEASE}/client-tools/pdi-ce-${PDI_VERSION}.zip \
    -P ${PENTAHO_HOME} \
# Unzip PDI to /opt/ directory
    && /usr/bin/unzip -q ${PENTAHO_HOME}/pdi-ce-${PDI_VERSION}.zip -d /opt/ \
# Clean up downloaded files
    && rm -R ${PENTAHO_HOME}/pdi-ce-${PDI_VERSION}.zip \
# Create directory for the kettle.properties file
    && mkdir ${KETTLE_HOME}/.kettle \
# Make pentaho user owner of both PENTAHO_HOME and KETTLE_HOME directories
    && chown -R ${PENTAHO_USER} ${PENTAHO_HOME} ${KETTLE_HOME}

# Install App dependent packages, if any
# Download Cpython Script Executor PDI plugin
RUN /usr/bin/wget --progress=dot:giga \
    https://github.com/pentaho-labs/pentaho-cpython-plugin/releases/download/v1.5/pentaho-cpython-plugin-package-1.5.zip \
    -P ${PENTAHO_HOME} \
# Unzip plugin to /opt/data-integration/steps directory
    && /usr/bin/unzip -q ${PENTAHO_HOME}/pentaho-cpython-plugin-package-1.5.zip -d /opt/data-integration/plugins/steps \
# Clean up downloaded files
    && rm -R ${PENTAHO_HOME}/pentaho-cpython-plugin-package-1.5.zip

# Install python packages required by the CPython executor PDI plugin
RUN apt-get -y update \
    && apt-get install python3-pip -y \
    && pip install pandas kafka-python scipy sklearn matplotlib \
    && mv /usr/bin/python3 /usr/bin/python

# Set Python path
ENV PATH=${PATH}:/usr/bin/python

USER ${PENTAHO_USER}

# Set working directory
WORKDIR ${KETTLE_HOME}