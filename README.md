# SupabaseLogQuery

There are 2 ways to handle logs:

## I want to analyze my PostgreSQL logs

We can create a table called `postgres_log` and import the log file to that table.  Now you can query that table and analyze it to your heart's content.  Note that ALL of the fields in this table are defined as `TEXT` even though many of them should be `DATE` or `INTEGER` types.  This is because there are malformed log records that would break the import process, so we just import everything as text for now.

### Step 1 Create the log table
Run `01_create_log_table.sql` to create the table.

### Step 2 Create the import function
Run `02_create_import_function` to create the function `import_postgres_log()`.

### Step 3 Run the import function
Execute the following query:
`select import_postgres_log()`

This will import the log file into your `postgres_log` table and show you how many records were processed (lines read from the log table) and how many records were added to the `postgres_log` table.  We ignore duplicate records, so each new time you run this function, you'll probably only see a few records added, depending on how long it's been since you ran the import.

### Step 4 Analyze your logs
To view the last 100 log entries:
`select * from postgres_log order by log_time desc limit 100;`

## I just want to dump the contents of my log file to the screen
The log file itself is in CSV format, and may contain errors, and it's ugly, but if you just want super quick and dirty access to it, follow these steps:

### Step 1 Create the FDW (Foreign Data Wrapper)
Run the contents of the file `SupabaseRawLogQuery.sql`.

(This script uses a foreign data wrapper, `file_fdw` to access the csv log file on your Supabase server instance.)

### Step 2
Read the most recent 100 entries as RAW TEXT from the log file:

`SELECT log_entry from postgres_log_text LIMIT 100;`





