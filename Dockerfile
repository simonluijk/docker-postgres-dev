FROM ubuntu:trusty
MAINTAINER simon@simonluijk.com

ENV DEBIAN_FRONTEND noninteractive
ENV REFRESHED_AT 2015-02-25
RUN echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
    apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y software-properties-common python-software-properties && \
    apt-get clean && \
    rm -rf /var/cache/apt/*

RUN apt-get install -y postgresql postgresql-client \
    postgis postgresql-9.3-postgis-2.1

EXPOSE 5432
ADD start.sh /usr/bin/start.sh
ENTRYPOINT ["/usr/bin/start.sh"]
CMD [""]
