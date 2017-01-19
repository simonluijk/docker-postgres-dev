FROM debian:jessie
MAINTAINER simon@simonluijk.com

RUN echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y apt-utils wget telnet curl cron && \
    apt-get clean && rm -rf /var/cache/apt/*

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" \
    | tee /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | apt-key add -

ENV PG_VERSION=9.5

RUN apt-get update && \
    apt-get install -y  postgresql-9.5 \
                        postgresql-9.5-postgis-2.2 && \
    apt-get clean && rm -rf /var/cache/apt/*

ENV PGCONF /etc/postgresql/$PG_VERSION/main
ENV PGDATA /var/lib/postgresql/$PG_VERSION/main
ENV PATH /usr/lib/postgresql/$PG_VERSION/bin:$PATH

RUN sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGCONF"/postgresql.conf
RUN { echo; echo "host all all 0.0.0.0/0 trust"; } >> "$PGCONF"/pg_hba.conf

RUN mkdir -p /var/run/postgresql/$PG_VERSION-main.pg_stat_tmp && \
    chown postgres.postgres /var/run/postgresql/$PG_VERSION-main.pg_stat_tmp

VOLUME  ["/var/log/postgresql", "/var/lib/postgresql"]

EXPOSE 5432
ADD start.sh /opt/start.sh
ENTRYPOINT ["/opt/start.sh"]
