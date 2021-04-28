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
--
-- create an alternate table that queries the entire log record as a line of text
-- in case of corrupted logs, which will not parse correctly
--
-- use this table in case you get the error "extra data after last expected column"
--
CREATE FOREIGN TABLE IF NOT EXISTS postgres_log_text
(line text) SERVER logserver OPTIONS (filename 'pg_log/postgresql.csv', format 'text');

-- query the log as csv

SELECT log_time, message, detail from postgres_log LIMIT 20;
 
-- query the log as text (after error "extra data after last expected column")

SELECT log_time, message, detail from postgres_log_text LIMIT 20;

-- import entire log file to a database table for further analysis 
-- CREATE TABLE postgres_log_snapshot AS SELECT * FROM postgres_log;
