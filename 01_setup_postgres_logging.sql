CREATE TABLE IF NOT EXISTS postgres_log
(
  log_time text,
  user_name text,
  database_name text,
  process_id text,
  connection_from text,
  session_id text,
  session_line_num text,
  command_tag text,
  session_start_time text,
  virtual_transaction_id text,
  transaction_id text,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos text,
  context text,
  query text,
  query_pos text,
  location text,
  application_name text,
  extra text,
  PRIMARY KEY (session_id, session_line_num)
);

CREATE OR REPLACE FUNCTION import_postgres_log()
RETURNS TEXT AS 
$$
DECLARE count_original INTEGER;
DECLARE count_processed INTEGER;
DECLARE count_final INTEGER;
DECLARE count_added INTEGER;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS postgres_log_tmp 
    ON COMMIT DROP
    AS
    SELECT * 
    FROM postgres_log
    WITH NO DATA;

    COPY postgres_log_tmp FROM '/var/lib/postgresql/data/pg_log/postgresql.csv' WITH csv;
    SELECT COUNT(*) FROM postgres_log_tmp INTO count_processed;
    SELECT COUNT(*) FROM postgres_log INTO count_original;

    INSERT INTO postgres_log
    SELECT * FROM postgres_log_tmp
    ON CONFLICT DO NOTHING;
    SELECT COUNT(*) FROM postgres_log INTO count_final;
    SELECT count_final - count_original INTO count_added;

    RETURN CAST (count_processed AS TEXT) || ' records read from log file, ' || CAST (count_added AS TEXT) || ' added to log table';

END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION get_postgres_log(how_many INTEGER)
RETURNS SETOF postgres_log AS 
$$
SELECT import_postgres_log();
SELECT * from postgres_log ORDER BY log_time DESC LIMIT how_many;
$$ LANGUAGE SQL;
