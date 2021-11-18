# Base Image
FROM apache/airflow:2.1.3

USER root
# Install Airflow additional dependencies
RUN pip install --upgrade pip \
    apache-airflow-providers-docker \
    'apache-airflow[postgres]'

USER airflow

# Install non-airflow packages as non-root user
RUN pip install kafka-python


