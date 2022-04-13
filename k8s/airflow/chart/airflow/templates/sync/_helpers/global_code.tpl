{{/*
Code which is included in all python sync scripts.
*/}}
{{- define "airflow.sync.global_code" }}
####################
## Global Imports ##
####################
import logging
import os
import time
from string import Template
from typing import List, Dict, Optional


####################
## Global Configs ##
####################
# the path which Secret/ConfigMap are mounted to
CONF__TEMPLATES_PATH = "/mnt/templates"

# how frequently to check for Secret/ConfigMap updates
CONF__TEMPLATES_SYNC_INTERVAL = 10

# how frequently to re-sync objects (Connections, Pools, Users, Variables)
CONF__OBJECTS_SYNC_INTERVAL = 60


######################
## Global Functions ##
######################
def string_substitution(raw_string: Optional[str], substitution_map: Dict[str, str]) -> str:
    """
    Apply bash-like substitutions to a raw string.

    Example:
    - string_substitution("Hello!", None) -> "Hello!"
    - string_substitution("Hello ${NAME}!", {"NAME": "Airflow"}) -> "Hello Airflow!"
    """
    if raw_string and len(substitution_map) > 0:
        tpl = Template(raw_string)
        return tpl.safe_substitute(substitution_map)
    else:
        return raw_string


def template_mtime(template_name: str) -> float:
    """
    Return the modification-time of the file storing `template_name`
    """
    file_path = f"{CONF__TEMPLATES_PATH}/{template_name}"
    return os.stat(file_path).st_mtime


def template_value(template_name: str) -> str:
    """
    Return the contents of the file storing `template_name`
    """
    file_path = f"{CONF__TEMPLATES_PATH}/{template_name}"
    with open(file_path, "r") as f:
        return f.read()


def refresh_template_cache(template_names: List[str],
                           template_mtime_cache: Dict[str, float],
                           template_value_cache: Dict[str, str]) -> List[str]:
    """
    Refresh the provided dictionary caches of template values & mtimes.

    :param template_names: the names of all templates to refresh
    :param template_mtime_cache: the dictionary cache of template file modification-times
    :param template_value_cache: the dictionary cache of template values
    :return: the names of templates which changed
    """
    changed_templates = []
    for template_name in template_names:
        old_mtime = template_mtime_cache.get(template_name, None)
        new_mtime = template_mtime(template_name)
        # first, check if the files were modified
        if old_mtime != new_mtime:
            old_value = template_value_cache.get(template_name, None)
            new_value = template_value(template_name)
            # second, check if the value actually changed
            if old_value != new_value:
                template_value_cache[template_name] = new_value
                changed_templates += [template_name]
            template_mtime_cache[template_name] = new_mtime
    return changed_templates


def main(sync_forever: bool):
    # initial sync of template cache
    refresh_template_cache(
        template_names=VAR__TEMPLATE_NAMES,
        template_mtime_cache=VAR__TEMPLATE_MTIME_CACHE,
        template_value_cache=VAR__TEMPLATE_VALUE_CACHE
    )

    # initial sync of objects into Airflow DB
    sync_with_airflow()

    if sync_forever:
        # define variables used to track how long since last refresh/sync
        templates_sync_epoch = time.time()
        objects_sync_epoch = time.time()

        # main loop
        while True:
            # monitor for template secret/configmap updates
            if (time.time() - templates_sync_epoch) > CONF__TEMPLATES_SYNC_INTERVAL:
                logging.debug(f"template sync interval reached, re-syncing all templates...")
                changed_templates = refresh_template_cache(
                    template_names=VAR__TEMPLATE_NAMES,
                    template_mtime_cache=VAR__TEMPLATE_MTIME_CACHE,
                    template_value_cache=VAR__TEMPLATE_VALUE_CACHE
                )
                templates_sync_epoch = time.time()
                if changed_templates:
                    logging.info(f"template values have changed: [{','.join(changed_templates)}]")
                    sync_with_airflow()
                    objects_sync_epoch = time.time()

            # monitor for external changes to objects (like from UI)
            if (time.time() - objects_sync_epoch) > CONF__OBJECTS_SYNC_INTERVAL:
                logging.debug(f"sync interval reached, re-syncing all objects...")
                sync_with_airflow()
                objects_sync_epoch = time.time()

            # ensure we dont loop too fast
            time.sleep(0.5)
{{- end }}