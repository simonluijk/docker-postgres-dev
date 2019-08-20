#!/usr/bin/env bash

set -e

# if data file exists then no volumes have been mounted, otherwise start fresh
#service postgresql stop

if [ ! -f /var/lib/postgresql/$PG_VERSION/main/PG_VERSION ]; then
    su postgres -c "/usr/lib/postgresql/${PG_VERSION}/bin/initdb --pgdata ${PGDATA} -A peer";
    chown -Rf postgres:postgres ${PGDATA}
    chmod 700 ${PGDATA}
fi

# Stop postgres when exiting
trap "service postgresql stop; exit" SIGHUP SIGINT SIGTERM

# Start postgres
echo "Start Postgres and wait for start to finish ..."
su postgres -c "${PGBIN}/pg_ctl start -w"

# UTF8
su postgres -c "psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\"";
su postgres -c "psql -c \"DROP DATABASE template1;\"";
su postgres -c "psql -c \"CREATE DATABASE template1 WITH template = template0 encoding = 'UTF8';\"";
su postgres -c "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';\"";
su postgres -c "psql -d template1 -c \"VACUUM FREEZE;\""

# Create user and database
su postgres -c "psql -c \"CREATE USER docker WITH SUPERUSER PASSWORD 'docker';\"" || true;
su postgres -c "createdb --encoding=UTF8 --owner=docker docker" || true;

while true; do sleep 1; done
