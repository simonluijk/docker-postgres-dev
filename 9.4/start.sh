#!/usr/bin/env bash

set -e

# If data file exists then no volumes have been mounted, otherwise start fresh
if [ ! -f ${PGDATA}/PG_VERSION ]; then
    echo "Initilizing data directory..."
    mkdir -p ${PGDATA}
    chown postgres:postgres ${PGDATA}
    su postgres -c "${PGBIN}/initdb -D ${PGDATA}";
fi

# Stop postgres when exiting
trap "service postgresql stop; exit" SIGHUP SIGINT SIGTERM

# Start postgres
echo "Restarting postgres..."
service postgresql restart

# UTF8
echo "Setting up encoding..."
su postgres -c "psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\"";
su postgres -c "psql -c \"DROP DATABASE template1;\"";
su postgres -c "psql -c \"CREATE DATABASE template1 WITH template = template0 encoding = 'UTF8';\"";
su postgres -c "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';\"";
su postgres -c "psql -d template1 -c \"VACUUM FREEZE;\""

# Create user and database
echo "Creating docker user and database..."
su postgres -c "psql -c \"CREATE USER docker WITH SUPERUSER PASSWORD 'docker';\"" || true;
su postgres -c "createdb --encoding=UTF8 --owner=docker docker" || true;

echo "Looping..."
while true; do sleep 1; done
