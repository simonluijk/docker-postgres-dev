#!/usr/bin/env bash

set -e

# Stop existing postgres
service postgresql restart

# UTF8
su postgres -c "psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';\"";
su postgres -c "psql -c \"DROP DATABASE template1;\"";
su postgres -c "psql -c \"CREATE DATABASE template1 WITH template = template0 encoding = 'UTF8';\"";
su postgres -c "psql -c \"UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';\"";
su postgres -c "psql -d template1 -c \"VACUUM FREEZE;\""

# Create user and database
su postgres -c "psql -c \"CREATE USER docker WITH SUPERUSER PASSWORD 'docker';\""
su postgres -c "createdb --encoding=UTF8 --owner=docker docker"

# GIS
su postgres -c "psql -d docker -f /usr/share/postgresql/$PG_VERSION/contrib/postgis-$GIS_VERSION/postgis.sql"
su postgres -c "psql -d docker -f /usr/share/postgresql/$PG_VERSION/contrib/postgis-$GIS_VERSION/spatial_ref_sys.sql"
su postgres -c "psql -d docker -f /usr/share/postgresql/$PG_VERSION/contrib/postgis-$GIS_VERSION/postgis_comments.sql"
su postgres -c "psql -d docker -c \"GRANT SELECT ON spatial_ref_sys TO PUBLIC;\""
su postgres -c "psql -d docker -c \"GRANT ALL ON geometry_columns TO docker;\""

while true; do sleep 1; done
