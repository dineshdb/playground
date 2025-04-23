# PostgreSQL + Replica + PgCat Playground

This project demonstrates a PostgreSQL primary-replica setup with PgCat for
read/write splitting.

## Services

- **postgres-primary**: Primary database (postgres:latest) on port 5432
- **postgres-replica**: Replica database (postgres:latest) on port 5433
- **pgcat**: Proxy/load balancer handling read/write splitting (port 6432)

## Usage

1. Start services:
   ```
   docker-compose up -d
   ```
2. Run the tests
   ```
   bash tests.sh
   ```
3. Check the pgcat logs
   ```
   podman logs -f pgcat
   ```

## Results

Currently, pgcat shows following behaviors

- To replica
  - Any select queries that does not include a transaction, e.g. `SELECT 1;`
- To primary
  - Any query update queries that modify the data, e.g.
    `UPDATE test_table SET x = x + 1;`
  - Any select and then update query, e.g.
    `SELECT x FROM test_table; UPDATE test_table SET x = x + 2;`
  - Any select query with transaction, e.g.
    `BEGIN; SELECT x FROM test_table; COMMIT;`
    - This might seem to be unnecessary, but this does guarantee to get latest
      data. So it might be better to selectively update our code depending upon
      if slightly stale data from replica is fine or not.
