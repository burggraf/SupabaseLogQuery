CREATE EXTENSION IF NOT EXISTS file_fdw;
CREATE SERVER IF NOT EXISTS logserver FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE IF NOT EXISTS postgres_log_text
(log_entry text)
 SERVER logserver OPTIONS (program 'tac pg_log/postgresql.csv', format 'text');

-- 
-- read the most recent 20 entries from the log file
--
SELECT log_entry from postgres_log_text LIMIT 20;
