{{/*
The python script to apply airflow database migrations.
*/}}
{{- define "airflow.db_migrations.db_migrations.py" }}
#############
## Imports ##
#############
import logging
import time
from airflow.utils.db import upgradedb


#############
## Configs ##
#############
log = logging.getLogger(__file__)
log.setLevel("INFO")

# how frequently to check for unapplied migrations
CONF__CHECK_MIGRATIONS_INTERVAL = {{ .Values.airflow.dbMigrations.checkInterval }}


###############
## Functions ##
###############
{{- if .Values.airflow.legacyCommands }}
# imports required for the following functions
import os
import airflow
from airflow import settings

# modified from https://github.com/apache/airflow/blob/2.1.0/airflow/utils/db.py#L583-L592
def _get_alembic_config():
    from alembic.config import Config

    package_dir = os.path.abspath(os.path.dirname(airflow.__file__))
    directory = os.path.join(package_dir, 'migrations')
    config = Config(os.path.join(package_dir, 'alembic.ini'))
    config.set_main_option('script_location', directory.replace('%', '%%'))
    config.set_main_option('sqlalchemy.url', settings.SQL_ALCHEMY_CONN.replace('%', '%%'))
    return config


# copied from https://github.com/apache/airflow/blob/2.1.0/airflow/utils/db.py#L595-L622
def check_migrations(timeout):
    """
    Function to wait for all airflow migrations to complete.
    :param timeout: Timeout for the migration in seconds
    :return: None
    """
    from alembic.runtime.migration import MigrationContext
    from alembic.script import ScriptDirectory

    config = _get_alembic_config()
    script_ = ScriptDirectory.from_config(config)
    with settings.engine.connect() as connection:
        context = MigrationContext.configure(connection)
        ticker = 0
        while True:
            source_heads = set(script_.get_heads())
            db_heads = set(context.get_current_heads())
            if source_heads == db_heads:
                break
            if ticker >= timeout:
                raise TimeoutError(
                    f"There are still unapplied migrations after {ticker} seconds. "
                    f"Migration Head(s) in DB: {db_heads} | Migration Head(s) in Source Code: {source_heads}"
                )
            ticker += 1
            time.sleep(1)
            log.info('Waiting for migrations... %s second(s)', ticker)
{{- else }}
from airflow.utils.db import check_migrations
{{- end }}


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
{{- /* if running as a Job, only run the initial check & apply */ -}}
{{- if .Values.airflow.dbMigrations.runAsJob }}
main(sync_forever=False)
{{- else }}
main(sync_forever=True)
{{- end }}

{{- end }}