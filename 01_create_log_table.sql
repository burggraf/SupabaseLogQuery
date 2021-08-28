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
  extra text
  PRIMARY KEY (session_id, session_line_num)
);
