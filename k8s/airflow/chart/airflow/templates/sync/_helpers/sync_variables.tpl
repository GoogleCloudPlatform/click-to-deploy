{{/*
The python sync script for variables.
*/}}
{{- define "airflow.sync.sync_variables.py" }}
############################
#### BEGIN: GLOBAL CODE ####
############################
{{- include "airflow.sync.global_code" . }}
##########################
#### END: GLOBAL CODE ####
##########################

#############
## Imports ##
#############
from airflow.models import Variable
from airflow.utils.db import create_session


#############
## Classes ##
#############
class VariableWrapper(object):
    def __init__(
            self,
            key: str,
            val: str,
    ):
        self.key = key
        self._val = val

    @property
    def val(self) -> str:
        return string_substitution(self._val, VAR__TEMPLATE_VALUE_CACHE)

    def as_variable(self) -> Variable:
        return Variable(
            key=self.key,
            val=self.val
        )


###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = [
  {{- range $k, $v := .Values.airflow.variablesTemplates }}
  {{ $k | quote }},
  {{- end }}
]
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}
VAR__VARIABLE_WRAPPERS = {
  {{- range .Values.airflow.variables }}
  {{ .key | quote }}: VariableWrapper(
    key={{ (required "each `key` in `airflow.variables` must be non-empty!" .key) | quote }},
    val={{ (required "each `value` in `airflow.variables` must be non-empty!" .value) | quote }},
  ),
  {{- end }}
}


###############
## Functions ##
###############
def compare_variables(v1: Variable, v2: Variable) -> bool:
    """
    Check if two Variable objects are identical.
    """
    return v1.key == v2.key and v1.val == v2.val


def sync_variable(variable_wrapper: VariableWrapper) -> None:
    """
    Sync the Variable defined by a provided VariableWrapper into the airflow DB.
    """
    v_key = variable_wrapper.key
    v_new = variable_wrapper.as_variable()

    variable_added = False
    variable_updated = False

    with create_session() as session:
        v_old = session.query(Variable).filter(Variable.key == v_key).first()
        if not v_old:
            logging.info(f"Variable=`{v_key}` is missing, adding...")
            session.add(v_new)
            variable_added = True
        else:
            if compare_variables(v_new, v_old):
                pass
            else:
                logging.info(f"Variable=`{v_key}` exists but has changed, updating...")
                v_old.val = v_new.val
                variable_updated = True

    if variable_added:
        logging.info(f"Variable=`{v_key}` was successfully added.")
    if variable_updated:
        logging.info(f"Variable=`{v_key}` was successfully updated.")


def sync_all_variables(variable_wrappers: Dict[str, VariableWrapper]) -> None:
    """
    Sync all variables in provided `variable_wrappers`.
    """
    logging.info("BEGIN: airflow variables sync")
    for variable_wrapper in variable_wrappers.values():
        sync_variable(variable_wrapper)
    logging.info("END: airflow variables sync")


def sync_with_airflow() -> None:
    """
    Preform a sync of all objects with airflow (note, `sync_with_airflow()` is called in `main()` template).
    """
    sync_all_variables(variable_wrappers=VAR__VARIABLE_WRAPPERS)


##############
## Run Main ##
##############
{{- if .Values.airflow.variablesUpdate }}
main(sync_forever=True)
{{- else }}
main(sync_forever=False)
{{- end }}

{{- end }}