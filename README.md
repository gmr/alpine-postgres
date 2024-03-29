# alpine-postgres

Docker image with a small disk footprint for PostgreSQL that includes:

- [ossp-uuid](https://github.com/sean-/ossp-uuid)
- [pg_cron](https://github.com/citusdata/pg_cron)
- [pglifecycle](https://github.com/gmr/pglifecycle)
- [pgTap](http://pgtap.org)
- [pgq](http://pgq.github.io)
- [plpgsql_check](https://github.com/okbob/plpgsql_check)
- [pgxnclient](https://pypi.org/project/pgxnclient/)

![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gmr/alpine-postgres.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/gavinmroy/alpine-postgres.svg)
![Docker Stars](https://img.shields.io/docker/stars/gavinmroy/alpine-postgres.svg)

## Image Tags

- ``gavinmroy/alpine-postgres:latest`` reflects the state of master
- ``gavinmroy/alpine-postgres:[PG_VERSION]-[RELEASE]`` reflects tagged releases

## Example Usage

```bash
docker run --name postgres -d -p 5432:5432 gavinmroy/alpine-postgres:13.3-0-0
```

## Startup DDL / SQL

To have DDL or other SQL automatically applied to the database on startup,
mount the volume  `/docker-entrypoint-initdb.d` to a directory with the
SQL files you want to run.

## Running pgTap Tests

To run pgTap tests you must mount your test directory to the container.

Example usage:

```bash
docker pull gavinmroy/postgres:13.3-0-0
docker run -d --name pgsql-testing -v /path/to/tests:/tests -p 5432 gavinmroy/alpine-postgres:13.3-0-0
docker exec -t -i pgsql-testing pg_prove -v /tests/*.sql
```
