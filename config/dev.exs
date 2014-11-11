# development config
use Mix.Config

config :epic_db,
  amqp_conn_string: System.get_env("AMQP_CONN_STRING") || "amqp://guest:guest@localhost",
  elasticsearch_base_url: System.get_env("ES_HOST") || "localhost",
  elasticsearch_port: System.get_env("ES_PORT") || 9200
