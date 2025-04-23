#!/usr/bin/env -S pkgx +psql

# Load environment variables
set -o allexport; 
source .env; 
set +o allexport

# Function to execute a SQL query and capture the server port
execute_query() {
    local query="$1"
    local expected_host="$2"
    local result_host

    result_host=$(pkgx psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -A  -c "$query")
}

# Test cases
echo "Running tests..."

# Read-only query should go to replica (port 5433)
execute_query "SELECT 1;" "replica"

# # Write query should go to primary (port 5432)
execute_query "UPDATE test_table SET x = x + 1;" "primary"


# # Mixed query should go to primary (port 5432)
execute_query "SELECT x FROM test_table; UPDATE test_table SET x = x + 2;" "primary"

# # Read-only transaction should go to replica (port 5433)
execute_query "BEGIN; SELECT x FROM test_table; COMMIT;" "replica"

