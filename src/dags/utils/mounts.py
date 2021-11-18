from os import environ
from docker.types import Mount


HOST_PDI_SRC_PATH = environ.get('HOST_PDI_SRC_PATH')
HOST_PDI_KET_PATH = environ.get('HOST_PDI_KET_PATH')
HOST_PDI_JND_PATH = environ.get('HOST_PDI_JND_PATH')
HOST_PDI_LOG_PATH = environ.get('HOST_PDI_LOG_PATH')
# HOST_PDI_PLG_PATH = environ.get('HOST_PDI_PLG_PATH')
# HOST_WRG_SRC_PATH = environ.get('HOST_WRG_SRC_PATH')

class PDIMount:

    pdi_src = Mount(source=HOST_PDI_SRC_PATH, target="/home/pentaho/pdi", type="bind")
    pdi_ketl = Mount(source=f"{HOST_PDI_KET_PATH}/kettle.properties", target="/opt/data-integration/.kettle/kettle.properties", type="bind")
    pdi_jndi = Mount(source=HOST_PDI_JND_PATH, target="/opt/data-integration/simple-jndi", type="bind")
    pdi_logs = Mount(source=HOST_PDI_LOG_PATH, target="/opt/data-integration/logs", type="bind")
    # pdi_plug = Mount(source=HOST_PDI_PLG_PATH, target="/opt/data-integration/plugins/steps", type="bind")

    MOUNTS = [pdi_src, pdi_ketl, pdi_jndi, pdi_logs]