#!/usr/bin/env bash


if [ ! -e "/data/postgresql.conf" ]; then
    set -m

    # Stop existing postgres
    service postgresql stop

    # Setup conf files
    chown postgres:postgres /data
    cp /etc/postgresql/9.3/main/postgresql.conf /data/postgresql.conf
    cp /etc/postgresql/9.3/main/pg_hba.conf /data/pg_hba.conf
    sed -i "/^data_directory*/ s|/var/lib/postgresql/9.3/main|/data/main|" \
        /data/postgresql.conf
    sed -i "/^hba_file*/ s|/etc/postgresql/9.3/main/pg_hba.conf|/data/pg_hba.conf|" \
        /data/postgresql.conf

    # Create data directory
    mkdir -p /data/main
    chown postgres /data/*
    chgrp postgres /data/*
    chmod 700 /data
    chmod 700 /data/main
    su postgres -c "/usr/lib/postgresql/9.3/bin/initdb -D /data/main"

    # Give access to external IPs
    sed -i "/^#listen_addresses/i listen_addresses='*'" /data/postgresql.conf
    sed -i "/^# DO NOT DISABLE\!/i # Allow access from any IP address" \
        /data/pg_hba.conf
    sed -i "/^# DO NOT DISABLE\!/i host all all 0.0.0.0/0 md5\n\n\n" \
        /data/pg_hba.conf

    # Start PostgreSQL
    su postgres -c "/usr/lib/postgresql/9.3/bin/postgres -D /data/main -c config_file=/data/postgresql.conf" &
    sleep 5

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
    su postgres -c "psql -d docker -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql"
    su postgres -c "psql -d docker -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql"
    su postgres -c "psql -d docker -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis_comments.sql"
    su postgres -c "psql -d docker -c \"GRANT SELECT ON spatial_ref_sys TO PUBLIC;\""
    su postgres -c "psql -d docker -c \"GRANT ALL ON geometry_columns TO docker;\""

    # Bring database back into the foreground.
    fg;
else
    su postgres -c "/usr/lib/postgresql/9.3/bin/postgres -D /data/main -c config_file=/data/postgresql.conf"
fi
