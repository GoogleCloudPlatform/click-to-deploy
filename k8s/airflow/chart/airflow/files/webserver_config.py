from airflow import configuration as conf
from flask_appbuilder.security.manager import AUTH_DB

# the SQLAlchemy connection string
SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')

# use embedded DB for auth
AUTH_TYPE = AUTH_DB
