# SupabaseLogQuery

There are 2 ways to handle logs:

## I want to analyze my PostgreSQL logs

We can create a table called `postgres_log` and import the log file to that table.  Now you can query that table and analyze it to your heart's content.  Note that ALL of the fields in this table are defined as `TEXT` even though many of them should be `DATE` or `INTEGER` types.  This is because there are malformed log records that would break the import process, so we just import everything as text for now.

### Step 1 Create the log table and functions to import and query the log table
Run `01_setup_postgres_logging.sql` to create the table.

### Step 2 Import and query the log in a single step!
As shown in `02_sample_query.sql` you can now just run:

`select * from get_postgres_log(100);`
This will show the last 100 entries from the log table.  (Behind the scenes we are imported the entire log file to our table and ignoring duplicates, but that's not important for you to know in order to use the results of this query.)

### Manually import the log file
Execute the following query:
`select import_postgres_log()`

This will import the log file into your `postgres_log` table and show you how many records were processed (lines read from the log table) and how many records were added to the `postgres_log` table.  We ignore duplicate records, so each new time you run this function, you'll probably only see a few records added, depending on how long it's been since you ran the import.

### Manually query the `postgres_log` table
To view the last 100 log entries:
`select * from postgres_log order by log_time desc limit 100;`
Or you can sort or limit any way you like.

## I just want to dump the contents of my log file to the screen
The log file itself is in CSV format, and may contain errors, and it's ugly, but if you just want super quick and dirty access to it, follow these steps:

### Step 1 Create the FDW (Foreign Data Wrapper)
Run the contents of the file `SupabaseRawLogQuery.sql`.

(This script uses a foreign data wrapper, `file_fdw` to access the csv log file on your Supabase server instance.)

### Step 2
Read the most recent 100 entries as RAW TEXT from the log file:

`SELECT log_entry from postgres_log_text LIMIT 100;`





