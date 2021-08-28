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