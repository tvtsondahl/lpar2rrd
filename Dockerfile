#!/usr/bin/docker build .
#
# VERSION               1.0

FROM       alpine:latest
MAINTAINER jirka@dutka.net

ENV HOSTNAME XoruX
ENV VI_IMAGE 1

# create file to see if this is the firstrun when started
RUN touch /firstrun

RUN apk update && apk add \
    bash \
    wget \
    supervisor \
    busybox-suid \
    apache2 \
    bc \
    net-snmp \
    net-snmp-tools \
    rrdtool \
    perl-rrd \
    perl-xml-simple \
    perl-xml-libxml \
    perl-net-ssleay \
    perl-crypt-ssleay \
    perl-net-snmp \
    net-snmp-perl \
    perl-lwp-protocol-https \
    perl-date-format \
    perl-dbd-pg \
    perl-io-tty \
    perl-want \
    # perl-font-ttf \
    net-tools \
    bind-tools \
    libxml2-utils \
    # snmp-mibs-downloader \
    openssh-client \
    ttf-dejavu \
    graphviz \
    vim \
    rsyslog \
    tzdata \
    sudo \
    less \
    ed \
    sharutils \
    make \
    tar \
    perl-dev \
    perl-app-cpanminus \
    sqlite \
    perl-dbd-pg \
    perl-dbd-sqlite \
    iproute2 \
    lsblk \
    procps \
    diffutils

# perl-font-ttf fron testing repo (needed for PDF reports)
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community perl-font-ttf
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing sblim-wbemcli

# install perl PDF API from CPAN
RUN cpanm -l /usr -n PDF::API2

# setup default user
RUN addgroup -S lpar2rrd 
RUN adduser -S lpar2rrd -G lpar2rrd -s /bin/bash

# configure Apache
COPY configs/apache2/lpar2rrd.conf /etc/apache2/sites-available/
COPY configs/apache2/htpasswd /etc/apache2/conf/
COPY configs/apache2/hardening.conf /etc/apache2/conf.d

# change apache user to lpar2rrd
RUN sed -i 's/^User apache/User lpar2rrd/g' /etc/apache2/httpd.conf

# disable status module
RUN sed -i '/mod_status.so/ s/^#*/#/' /etc/apache2/httpd.conf

# add product installations
ENV LPAR_VER_MAJ "7.30"
ENV LPAR_VER_MIN ""

ENV LPAR_VER "$LPAR_VER_MAJ$LPAR_VER_MIN"

# expose ports for SSH, HTTP, HTTPS and LPAR2RRD daemon
EXPOSE 80 8162

COPY configs/crontab /var/spool/cron/crontabs/lpar2rrd
RUN chmod 640 /var/spool/cron/crontabs/lpar2rrd && chown lpar2rrd.cron /var/spool/cron/crontabs/lpar2rrd

# download tarballs from SF
# ADD http://downloads.sourceforge.net/project/lpar2rrd/lpar2rrd/$LPAR_SF_DIR/lpar2rrd-$LPAR_VER.tar /home/lpar2rrd/
# ADD http://downloads.sourceforge.net/project/stor2rrd/stor2rrd/$STOR_SF_DIR/stor2rrd-$STOR_VER.tar /home/stor2rrd/

# download tarballs from official website
ADD https://lpar2rrd.com/download-static/lpar2rrd-$LPAR_VER.tar /tmp/
RUN mkdir -p /opt/lpar2rrd-agent
ADD https://lpar2rrd.com/agent/lpar2rrd-agent.pl.gz /opt/lpar2rrd-agent/

# extract tarballs
WORKDIR /tmp
RUN tar xvf lpar2rrd-$LPAR_VER.tar
RUN gunzip /opt/lpar2rrd-agent/lpar2rrd-agent.pl.gz && chmod +r /opt/lpar2rrd-agent/lpar2rrd-agent.pl

COPY supervisord.conf /etc/
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

#RUN mkdir -p /home/lpar2rrd/lpar2rrd/data
#RUN mkdir -p /home/lpar2rrd/lpar2rrd/etc

VOLUME [ "/home/lpar2rrd" ]

ENTRYPOINT [ "/startup.sh" ]

