#!/usr/bin/env bash

set -e

# Stop postgres when exiting
trap "service postgresql stop; exit" SIGHUP SIGINT SIGTERM

# Start postgres
service postgresql restart

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
