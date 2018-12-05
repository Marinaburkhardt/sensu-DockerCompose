FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y wget apt-utils apt-transport-https \
  && wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add - \
  && echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list \
  && apt-get update \
  && apt-get install -y sensu supervisor uchiwa

COPY configurationFiles/uchiwa.json /etc/sensu/
COPY configurationFiles/config.json /etc/sensu/ 
COPY configurationFiles/transport.json /etc/sensu/conf.d/
COPY configurationFiles/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Sensu client on localhost
COPY configurationFiles/client.json /etc/sensu/conf.d/client.json

#Install checks
RUN sensu-install -p disk-checks \
    && sensu-install -p cpu-checks \
    && sensu-install -p memory-checks

#Configure checks
COPY configurationFiles/check_disk.json /etc/sensu/conf.d/check_disk.json
COPY configurationFiles/check-memory.json /etc/sensu/conf.d/check-memory.json
COPY configurationFiles/check-cpu.json /etc/sensu/conf.d/check-cpu.json

EXPOSE 4567
EXPOSE 3000

CMD ["/usr/bin/supervisord"]

