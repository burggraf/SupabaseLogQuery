--DROP TABLE IF EXISTS postgres_log CASCADE;
--DROP FUNCTION IF EXISTS create_postgres_log_table;
--DROP FUNCTION IF EXISTS import_postgres_log;
--DROP FUNCTION IF EXISTS get_postgres_log;

-- create the postgres_log table depending on your version of PostgreSQL
-- version 13 requires an extra field, version 12 does not
CREATE OR REPLACE FUNCTION create_postgres_log_table()
RETURNS VOID AS 
$$
DECLARE pg_major_version TEXT;
BEGIN
  SELECT substr(version(),12,2) INTO pg_major_version;
  EXECUTE '
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
    application_name text,'
    || CASE WHEN pg_major_version < '13' THEN '' ELSE 'extra text,' END || --extra text for pg13, otherwise skip this field for pg12
    'PRIMARY KEY (session_id, session_line_num)
  );
  ';
END;
$$ LANGUAGE PLPGSQL;
select create_postgres_log_table();

CREATE OR REPLACE FUNCTION import_postgres_log()
RETURNS TEXT AS 
$$
DECLARE 
  count_original INTEGER;
  count_processed INTEGER;
  count_final INTEGER;
  count_added INTEGER;
  data_dir TEXT;
BEGIN
    SELECT setting || '/pg_log/postgresql.csv' from pg_settings where name = 'data_directory' INTO data_dir;
    CREATE TEMP TABLE IF NOT EXISTS postgres_log_tmp 
    ON COMMIT DROP
    AS
    SELECT * 
    FROM postgres_log
    WITH NO DATA;

    EXECUTE 'COPY postgres_log_tmp FROM ''' ||  data_dir || ''' WITH csv';

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

