# escape=`
#Set escape character so that doesn't interfere with Windows file paths
# (must be first line of dockerfile, which is why this comment is second)
#
# TODO: Remove dev user, startup script

####### VERSIONS #######
FROM debian:stretch

LABEL maintainer "jake.gillberg@gmail.com"

#Non-interactive console during docker build process
ARG DEBIAN_FRONTEND=noninteractive

#Install apt-utils so debconf doesn't complain about configuration for every
# other install
RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
      apt-utils `
  && rm -rf /var/lib/apt/lists/*

#Set the locale
RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
    locales `
  && rm -rf /var/lib/apt/lists/* `
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen `
  && dpkg-reconfigure locales `
  && echo ': "${LANG:=en_US.utf8}"; export LANG' >> /etc/profile

#Start the entrypoint script
RUN echo '#!/bin/bash' > entrypoint.sh `
  && chmod 0700 /entrypoint.sh

#Create regular user (dev) and groups
RUN `
  adduser --gecos "" --shell /bin/bash --disabled-password dev

#######

RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
      cpanminus `
      curl `
      openjdk-8-jdk `
      time `
      unzip `
  && rm -rf /var/lib/apt/lists/* `
  && curl -LO http://www.cs.cornell.edu/projects/civitas/releases/civitas-0.7.1.zip `
  && unzip civitas-0.7.1.zip

####### STARTUP #######
RUN `
  apt-get update `
  && apt-get install -y --no-install-recommends `
      gosu `
  && rm -rf /var/lib/apt/lists/* `
  && rm -rf /tmp/* `
  && echo 'exec gosu dev /bin/bash' >> /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
