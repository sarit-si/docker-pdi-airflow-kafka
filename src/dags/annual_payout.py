from os import environ
from airflow import DAG
from airflow.models.variable import Variable
from airflow.utils.dates import days_ago

from airflow.operators.dummy import DummyOperator
from airflow.providers.docker.operators.docker import DockerOperator

from utils.mounts import PDIMount

# Get the AIRFLOW_VAR_DEMO_TOPIC_NAME and AIRFLOW_VAR_DEMO_TOPIC_CONSUMER env variables
# These 2 will decide the number of CONSUMER tasks to spawn on start up
TOPIC = Variable.get('DEMO_TOPIC_NAME')
PARTITIONS = int(Variable.get('DEMO_TOPIC_CONSUMERS'))

args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'depends_on_past': True,
    'wait_for_downstream': True,
    'catchup': False
}

with DAG('Annual_Payout', default_args=args, schedule_interval=None) as dag:

    start = DummyOperator(
        task_id='Start'
    )

    # Spawn a PDI container to run the producer.ktr transformation for pushing messages to Kafka
    producer = DockerOperator(
        task_id='Producer',
        command='pan.sh -file:/home/pentaho/pdi/producer.ktr \
            /param:topic={{ params.topic }}',
        params = {
            'topic' : TOPIC
        },
        api_version='auto',
        image='pdi',
        working_dir='/opt/data-integration',
        environment={
            'BOOTSTRAP_SERVERS' : environ.get('BOOTSTRAP_SERVERS'),
            'PENTAHO_DI_JAVA_OPTIONS' : environ.get('PENTAHO_DI_JAVA_OPTIONS'),
        },
        auto_remove=True,
        network_mode='myapp',
        docker_url='unix://var/run/docker.sock',
        mounts=PDIMount().MOUNTS
    )

    # Get a list of consumer tasks. Each task will spawn a PDI container and run the consumer.ktr inside it
    # The number of such consumer containers depends on the DEMO_TOPIC_CONSUMERS value.
    consumers = [

        DockerOperator(
            task_id=f'Consume_Partition_{partition}',
            command='pan.sh -file:/home/pentaho/pdi/consumer.ktr \
                /param:topic={{ params.topic }} \
                    /param:partition={{ params.partition }} \
                        /param:group_id={{ params.group_id }}',
            params={
                'topic' : TOPIC,
                'partition' : partition,
                'group_id' : 'myapp_group'
            },
            api_version='auto',
            image='pdi',
            working_dir='/opt/data-integration',
            environment={
                'BOOTSTRAP_SERVERS' : environ.get('BOOTSTRAP_SERVERS'),
                'PENTAHO_DI_JAVA_OPTIONS' : environ.get('PENTAHO_DI_JAVA_OPTIONS'),
            },
            auto_remove=True,
            network_mode='myapp',
            docker_url='unix://var/run/docker.sock',
            mounts=PDIMount().MOUNTS
        )
        for partition in range(PARTITIONS)
    ]


    stop = DummyOperator(
        task_id='Stop'
    )

    start >> producer >> consumers >> stop





