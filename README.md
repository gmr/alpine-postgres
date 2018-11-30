# alpine-postgres

Image with a small disk footprint for PostgreSQL that includes
[pgTap](http://pgtap.org), and [pgq](http://pgq.github.io).

## Image Tags

- ``gavinmroy/postgres:latest`` reflects the state of master
- ``gavinmroy/postgres:[VERSION]`` reflects tagged releases

## Example Usage

```bash
docker run --name postgres -d -p 5432:5432 gavinmroy/postgres:11.1
```

## Startup DDL / SQL

To have DDL or other SQL automatically applied to the database on startup,
mount the volume  `/docker-entrypoint-initdb.d` to a directory with the
SQL files you want to run.

## Running pgTap Tests

To run pgTap tests you must mount your test directory to the container.

Example usage:

```bash
docker pull gavinmroy/postgres:11.1
docker run -d --name pgsql-testing -v /path/to/tests:/tests -p 5432 gavinmroy/postgres:11.1
docker exec -t -i pgsql-testing pg_prove -v /tests/*.sql
```
