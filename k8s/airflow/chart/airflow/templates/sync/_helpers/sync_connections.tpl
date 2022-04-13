{{/*
The python sync script for connections.
*/}}
{{- define "airflow.sync.sync_connections.py" }}
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
from airflow.models import Connection
from airflow.utils.db import create_session


#############
## Classes ##
#############
class ConnectionWrapper(object):
    def __init__(
            self,
            conn_id: str,
            conn_type: str,
            {{- if not .Values.airflow.legacyCommands }}
            description: Optional[str] = None,
            {{- end }}
            host: Optional[str] = None,
            login: Optional[str] = None,
            password: Optional[str] = None,
            schema: Optional[str] = None,
            port: Optional[int] = None,
            extra: Optional[str] = None,
    ):
        self.conn_id = conn_id
        self.conn_type = conn_type
        {{- if not .Values.airflow.legacyCommands }}
        self.description = description
        {{- end }}
        self._host = host
        self._login = login
        self._password = password
        self._schema = schema
        self.port = port
        self._extra = extra

    @property
    def host(self) -> str:
        return string_substitution(self._host, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def login(self) -> str:
        return string_substitution(self._login, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def password(self) -> str:
        return string_substitution(self._password, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def schema(self) -> str:
        return string_substitution(self._schema, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def extra(self) -> str:
        return string_substitution(self._extra, VAR__TEMPLATE_VALUE_CACHE)

    def as_connection(self) -> Connection:
        return Connection(
            conn_id=self.conn_id,
            conn_type=self.conn_type,
            {{- if not .Values.airflow.legacyCommands }}
            description=self.description,
            {{- end }}
            host=self.host,
            login=self.login,
            password=self.password,
            schema=self.schema,
            port=self.port,
            extra=self.extra,
        )


###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = [
  {{- range $k, $v := .Values.airflow.connectionsTemplates }}
  {{ $k | quote }},
  {{- end }}
]
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}
VAR__CONNECTION_WRAPPERS = {
  {{- range .Values.airflow.connections }}
  {{ .id | quote }}: ConnectionWrapper(
    conn_id={{ (required "each `id` in `airflow.connections` must be non-empty!" .id) | quote }},
    conn_type={{ (required "each `type` in `airflow.connections` must be non-empty!" .type) | quote }},
    {{- if and (.description) (not $.Values.airflow.legacyCommands) }}
    description={{ .description | quote }},
    {{- end }}
    {{- if .host }}
    host={{ .host | quote }},
    {{- end }}
    {{- if .login }}
    login={{ .login | quote }},
    {{- end }}
    {{- if .password }}
    password={{ .password | quote }},
    {{- end }}
    {{- if .schema }}
    schema={{ .schema | quote }},
    {{- end }}
    {{- if .port }}
    {{- if not (or (typeIs "float64" .port) (typeIs "int64" .port)) }}
    {{- /* the type of a number could be float64 or int64 depending on how it was set */ -}}
    {{ required "each `port` in `airflow.connections` must be int-type!" nil }}
    {{- end }}
    port={{ .port }},
    {{- end }}
    {{- if .extra }}
    extra={{ .extra | quote }},
    {{- end }}
  ),
  {{- end }}
}


###############
## Functions ##
###############
def compare_connections(c1: Connection, c2: Connection) -> bool:
    """
    Check if two Connection objects are identical.
    """
    return (
            c1.conn_id == c2.conn_id
            and c1.conn_type == c2.conn_type
            {{- if not .Values.airflow.legacyCommands }}
            and c1.description == c2.description
            {{- end }}
            and c1.host == c2.host
            and c1.login == c2.login
            and c1.password == c2.password
            and c1.schema == c2.schema
            and c1.port == c2.port
            and c1.extra == c2.extra
    )


def sync_connection(connection_wrapper: ConnectionWrapper) -> None:
    """
    Sync the Connection defined by a provided ConnectionWrapper into the airflow DB.
    """
    c_id = connection_wrapper.conn_id
    c_new = connection_wrapper.as_connection()

    connection_added = False
    connection_updated = False

    with create_session() as session:
        c_old = session.query(Connection).filter(Connection.conn_id == c_id).first()
        if not c_old:
            logging.info(f"Connection=`{c_id}` is missing, adding...")
            session.add(c_new)
            connection_added = True
        else:
            if compare_connections(c_new, c_old):
                pass
            else:
                logging.info(f"Connection=`{c_id}` exists but has changed, updating...")
                c_old.conn_type = c_new.conn_type
                {{- if not .Values.airflow.legacyCommands }}
                c_old.description = c_new.description
                {{- end }}
                c_old.host = c_new.host
                c_old.login = c_new.login
                c_old.password = c_new.password
                c_old.schema = c_new.schema
                c_old.port = c_new.port
                c_old.extra = c_new.extra
                connection_updated = True

    if connection_added:
        logging.info(f"Connection=`{c_id}` was successfully added.")
    if connection_updated:
        logging.info(f"Connection=`{c_id}` was successfully updated.")


def sync_all_connections(connection_wrappers: Dict[str, ConnectionWrapper]) -> None:
    """
    Sync all connections in provided `connection_wrappers`.
    """
    logging.info("BEGIN: airflow connections sync")
    for connection_wrapper in connection_wrappers.values():
        sync_connection(connection_wrapper)
    logging.info("END: airflow connections sync")


def sync_with_airflow() -> None:
    """
    Preform a sync of all objects with airflow (note, `sync_with_airflow()` is called in `main()` template).
    """
    sync_all_connections(connection_wrappers=VAR__CONNECTION_WRAPPERS)


##############
## Run Main ##
##############
{{- if .Values.airflow.connectionsUpdate }}
main(sync_forever=True)
{{- else }}
main(sync_forever=False)
{{- end }}

{{- end }}