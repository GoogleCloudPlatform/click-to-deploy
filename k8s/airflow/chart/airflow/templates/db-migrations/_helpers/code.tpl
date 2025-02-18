{{/*
The python script to apply airflow database migrations.
*/}}
{{- define "airflow.db_migrations.db_migrations.py" }}
#############
## Imports ##
#############
import logging
import signal
import time
import sys
from airflow.utils.db import upgradedb


def signal_handler(sig, frame):
    print('Termination signal received.')
    sys.exit(0)


signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)


#############
## Configs ##
#############
log = logging.getLogger(__file__)
log.setLevel("INFO")

# how frequently to check for unapplied migrations
CONF__CHECK_MIGRATIONS_INTERVAL = 300


###############
## Functions ##
###############
from airflow.utils.db import check_migrations

def needs_db_migrations() -> bool:
    """
    Return a boolean representing if the database has unapplied migrations.
    """
    log_alembic = logging.getLogger("alembic.runtime.migration")
    log_alembic_level = log_alembic.level
    try:
        log_alembic.setLevel("WARN")
        check_migrations(0)
        log_alembic.setLevel(log_alembic_level)
        return False
    except TimeoutError:
        return True


def apply_db_migrations() -> None:
    """
    Apply any pending DB migrations.
    """
    log.info("-------- START - APPLY DB MIGRATIONS --------")
    upgradedb()
    log.info("-------- FINISH - APPLY DB MIGRATIONS --------")


def main(sync_forever: bool):
    # initial check & apply
    if needs_db_migrations():
        log.warning("there are unapplied db migrations, triggering apply...")
        apply_db_migrations()
    else:
        log.info("there are no unapplied db migrations, continuing...")

    if sync_forever:
        # define variable to track how long since last migrations check
        migrations_check_epoch = time.time()

        # main loop
        while True:
            if (time.time() - migrations_check_epoch) > CONF__CHECK_MIGRATIONS_INTERVAL:
                log.debug(f"check interval reached, checking for unapplied db migrations...")
                if needs_db_migrations():
                    log.warning("there are unapplied db migrations, triggering apply...")
                    apply_db_migrations()
                migrations_check_epoch = time.time()

            # ensure we dont loop too fast
            time.sleep(0.5)


##############
## Run Main ##
##############
main(sync_forever=True)

{{- end }}
