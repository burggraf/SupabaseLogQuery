CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS logserver FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE IF NOT EXISTS postgres_log
(
  log_time timestamp(3) with time zone,
  user_name text,
  database_name text,
  process_id integer,
  connection_from text,
  session_id text,
  session_line_num bigint,
  command_tag text,
  session_start_time timestamp with time zone,
  virtual_transaction_id text,
  transaction_id bigint,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos integer,
  context text,
  query text,
  query_pos integer,
  location text,
  application_name text)
 SERVER logserver OPTIONS (filename 'pg_log/postgresql.csv', format 'csv');
 -- query the log

 SELECT log_time, message, detail from postgres_log ORDER BY log_time DESC LIMIT 20;

 -- import the log to a database table for further analysis (last 1000 items)
 -- CREATE TABLE postgres_log_snapshot AS SELECT * FROM postgres_log ORDER BY log_time limit 1000;
